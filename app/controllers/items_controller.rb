require_dependency 'tag_parser'
require_dependency 'search'
require 'tempfile'
require 'mimetype_fu'
require 'zip/zip'

class ItemsController < ApplicationController
  # GET /items/:id
  def show
    @start_time = Time.new
    @item = Item.find params[:id]
    raise "No such item" unless @item

    if @item.variety == 'photo'
      @view_count = @item.view_count ||= 0
      @item.view_count += 1
      @item.save
    end

    @query = params[:q] || ''
    @index = params[:i].to_i

    search = Search.new( @query ).items

    # FIXME If the search results change and someone has an old URL, the index
    # will be wrong.  In order to avoid this the index parameter shouldn't be
    # used at all and this should be done some other way.
    @next = search.first :offset => @index + 1
    @prev = nil
    if @index > 0
      @prev = search.first :offset => @index - 1
    end

    if @prev
      @prev_url = item_path :id => @prev.id, :q => @query, :e => params[:e], :i => @index - 1
    end
    if @next
      @next_url = item_path :id => @next.id, :q => @query, :e => params[:e], :i => @index + 1
      @next_image_url = @next.resized_url 'large'
    end

    @tags = @item.tags.map { |tag| tag.label }.join( ', ' )

    @title = "Cheese"
    @title = @tags + " - Cheese" unless @tags.empty?
  end

  # GET /items/:id/download
  def download
    @item = Item.find params[:id]
    send_file @item.full_path, type: File.mime_type?( @item.path )
  end

  # GET /items/download_warning
  def download_warning
    @event = Event.find params[:id]
    @size = 0
    @event.items.each do |item|
      @size += File.size item.full_path
    end
  end

  # POST /items/download
  def download_pack
    t = Tempfile.new 'cheese-photos'
    Zip::ZipOutputStream.open( t.path ) do |zip|
      items = []
      if params[:ids]
        params[:ids].split( ',' ).each do |id|
          id.gsub! /^item_/, ''
          item = Item.find id
          items.push item
        end
      end

      if params[:event]
        event = Event.find params[:event]
        ids = event.items.each
      end

      items.each do |item|
        title = File.basename item.full_path
        zip.put_next_entry title
        zip.print IO.read( item.full_path )
      end
    end

    send_file t.path, type: 'application/zip', filename: 'cheese-photos.zip'
  end

  # POST /items/tags
  def tags
    data = JSON.parse params[:data]
    data.each do |item_id,tags|
      item_id =~ /(\d+)/ or next
      Item.transaction do
        item = Item.find $1.to_i
        item.tags.clear
        tags.each do |tag_id,val|
          next unless val == true
          tag = Tag.find tag_id.to_i
          item.tags.push tag
        end
        item.save
      end
    end
    render text: "OK"
  end
end
