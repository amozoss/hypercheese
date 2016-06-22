require_dependency 'user_serializer'

class UpdateActivityJob < ActiveJob::Base
  queue_as :default

  class Group
    attr :photo_count, true
    attr :video_count, true
    attr :item, true
    attr :ids, true
    def created_at
      @item.created_at
    end
  end

  def perform(*args)
    warn "ha ha"
    cutoff = 45.days.ago
    events = []
    events += Comment.includes(:item, :user).where('created_at > ?', cutoff).to_a
    events += Star.includes(:item, :user).where('created_at > ?', cutoff).to_a

    recent = Item.includes(:item_paths).where('deleted = 0').where('created_at > ?', cutoff)

    recent = recent.sort_by do |item|
      [item.directory, item.created_at]
    end

    groups = []
    last = Group.new
    recent.each do |item|
      if !last.item || last.item.directory != item.directory || item.created_at - last.item.created_at > 8.hours
        groups << last if last.item
        last = Group.new
      end
      last.item ||= item
      if item.variety == 'video'
        last.video_count ||= 0
        last.video_count += 1
      else
        last.photo_count ||= 0
        last.photo_count += 1
      end
      last.ids ||= []
      last.ids << item.id
    end
    groups << last if last.item

    events += groups
    events = events.sort_by(&:created_at).reverse

    sources = Source.where show_on_home: true
    sources = ActiveModel::ArraySerializer.new sources, each_serializer: SourceSerializer

    json = {
      activity: events,
      users: [],
      items: [],
      sources: sources
    }

    json[:activity].map! do |event|
      case event
      when Group
        json[:items].push event.item

        label = event.item.source.try(:label) || 'Unknown'

        {
          item_group: {
            created_at: event.created_at,
            photo_count: event.photo_count,
            video_count: event.video_count,
            source: label,
            ids: event.ids,
            item_id: event.item.id,
          }
        }
      when Comment
        comment = CommentSerializer.new(event).as_json
        comment.delete "users"
        json[:users].push event.user
        json[:items].push event.item
        comment
      when Star
        star = StarSerializer.new(event).as_json
        star.delete "users"
        json[:users].push event.user
        json[:items].push event.item
        star
      end
    end
    json[:users].uniq!
    json[:items].uniq!

    cache_path = Rails.root.join "tmp/activities"
    tmp = "#{cache_path}.#$$.tmp"

    File.binwrite tmp, json.to_json
    File.rename tmp, cache_path
  end
end
