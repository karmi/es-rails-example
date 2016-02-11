# Provides an `Importer` class to import data from the StackExchange dump
# to the database.

require 'pathname'
require 'nokogiri'
require 'ansi'
require 'ansi/progressbar'

STDOUT.sync = true
STDERR.sync = true

module StackExchange
  class Reader
    BATCH_SIZE = 100

    attr_reader :input

    def initialize(input, options={})
      @input = input
    end

    def count
      `/usr/bin/grep '<row' #{input.path} | /usr/bin/wc -l`.chomp.to_i
    end

    def basename(*args)
      File.basename(input, *args)
    end

    def each_batch &block
      buffer = []
      index  = 0
      input.rewind
      input.each do |line|
        next unless line =~ /^\s*<row/
        buffer << line
        index  += 1
        if index % BATCH_SIZE == 0
          yield buffer
          buffer = []
        end
      end

      yield buffer unless buffer.empty?
    end
  end

  class Importer
    attr_reader :path, :messages, :skipped

    def initialize(path, options={})
      @path = Pathname(path)
      @messages = []
      @skipped = 0
    end

    def import!
      import_users
      import_questions
      import_comments

      unless messages.empty?
        puts '-' * 80
        messages.each do |message|
          STDERR.puts message[:body].ansi(message[:color].to_sym)
        end
        puts '-' * 80
      end

      if skipped > 0
        STDERR.puts "Skipped #{skipped} rows"
        puts '-' * 80
      end
    end

    def import_users(filename='Users.xml')
      reader = Reader.new File.new(path.join(filename))
      bar = ANSI::Progressbar.new(filename, reader.count / Reader::BATCH_SIZE )

      reader.each_batch do |batch|
        batch.map do |row|
          attributes = Hash.from_xml(row)['row'].transform_keys { |key| key.underscore }

          # Normalize attributes
          #
          attributes['email']       = attributes['email_hash']
          attributes['date_joined'] = attributes['creation_date']
          attributes['url']         = attributes['website_url']
          attributes['description'] = attributes['about_me']
          attributes['votes_up']    = attributes['up_votes'].to_i
          attributes['votes_down']  = attributes['down_votes'].to_i
          attributes['age']         = attributes['age'].to_i

          User.create! attributes.slice(*User.attribute_names)
        end
        bar.inc
      end

      bar.finish
    end

    def import_questions(filename='Posts.xml')
      reader = Reader.new File.new(path.join(filename))
      bar = ANSI::Progressbar.new(filename, reader.count / Reader::BATCH_SIZE )

      reader.each_batch do |batch|
        batch.map do |row|
          attributes = Hash.from_xml(row)['row'].transform_keys { |key| key.underscore }

          klass = case attributes['post_type_id'].to_i
            when 1
              Question
            when 2
              Answer
            else
              @messages.push color: 'yellow',
                            body: "Skipped post [#{attributes['id']}] with post_type_id=#{attributes['post_type_id']}"
              @skipped += 1
              next
          end

          # Normalize attributes
          #
          attributes['owner_id'] = attributes['owner_user_id']
          attributes['rating']   = attributes['score']

          attributes['question_id'] = attributes['parent_id'] if klass == Answer

          klass.create! attributes.slice(*klass.attribute_names)
        end
        bar.inc
      end

      bar.finish
    end

    def import_comments(filename='Comments.xml')
      reader = Reader.new File.new(path.join(filename))
      bar = ANSI::Progressbar.new(filename, reader.count / Reader::BATCH_SIZE )

      reader.each_batch do |batch|
        batch.map do |row|
          attributes = Hash.from_xml(row)['row'].transform_keys { |key| key.underscore }

          # Normalize attributes
          #
          attributes['owner_id'] = attributes['user_id']
          attributes['rating']   = attributes['score']

          # Add parent
          attributes['commentable_id']   = attributes['post_id']
          attributes['commentable_type'] = case
            when Question.exists?(attributes['post_id'])
              'Question'
            when Answer.exists?(attributes['post_id'])
              'Answer'
            else
              @messages.push color: 'red',
                              body: "Skipped comment [#{attributes['id']}] because related post [#{attributes[id]}] was not found"
                @skipped += 1
                next
          end

          Comment.create! attributes.slice(*Comment.attribute_names)
        end
        bar.inc
      end

      bar.finish
    end
  end
end
