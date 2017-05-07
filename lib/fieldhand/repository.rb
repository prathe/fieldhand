require 'fieldhand/header'
require 'fieldhand/identify'
require 'fieldhand/logger'
require 'fieldhand/metadata_format'
require 'fieldhand/paginator'
require 'fieldhand/record'
require 'fieldhand/set'
require 'uri'

module Fieldhand
  # A repository is a network accessible server that can process the 6 OAI-PMH requests.
  #
  # See https://www.openarchives.org/OAI/openarchivesprotocol.html
  class Repository
    attr_reader :uri, :logger

    def initialize(uri, logger = Logger.null)
      @uri = uri.is_a?(::URI) ? uri : URI(uri)
      @logger = logger
    end

    def identify
      paginator.
        items('Identify', 'Identify').
        map { |identify| Identify.new(identify) }.
        first
    end

    def metadata_formats(identifier = nil)
      return enum_for(:metadata_formats, identifier) unless block_given?

      arguments = {}
      arguments['identifier'] = identifier if identifier

      paginator.
        items('ListMetadataFormats', 'ListMetadataFormats/metadataFormat', arguments).
        each do |format|
          yield MetadataFormat.new(format)
        end
    end

    def sets
      return enum_for(:sets) unless block_given?

      paginator.
        items('ListSets', 'ListSets/set').
        each do |set|
          yield Set.new(set)
        end
    end

    def records(metadata_prefix, arguments = {})
      return enum_for(:records, metadata_prefix, arguments) unless block_given?

      paginator.
        items('ListRecords', 'ListRecords/record', arguments.merge('metadataPrefix' => metadata_prefix)).
        each do |record|
          yield Record.new(record)
        end
    end

    def identifiers(metadata_prefix, arguments = {})
      return enum_for(:identifiers, metadata_prefix, arguments) unless block_given?

      paginator.
        items('ListIdentifiers', 'ListIdentifiers/header', arguments.merge('metadataPrefix' => metadata_prefix)).
        each do |header|
          yield Header.new(header)
        end
    end

    def get(identifier, metadata_prefix)
      paginator.
        items('GetRecord', 'GetRecord/record', 'metadataPrefix' => metadata_prefix, 'identifier' => identifier).
        map { |record| Record.new(record) }.
        first
    end

    private

    def paginator
      @paginator ||= Paginator.new(uri, logger)
    end
  end
end
