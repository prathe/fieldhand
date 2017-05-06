module Fieldhand
  # A record is metadata expressed in a single format.
  #
  # See https://www.openarchives.org/OAI/openarchivesprotocol.html#Record
  class Record
    attr_reader :element

    def initialize(element)
      @element = element
    end

    def status
      header.status
    end

    def identifier
      header.identifier
    end

    def datestamp
      header.datestamp
    end

    def sets
      header.sets
    end

    def metadata
      @metadata ||= element.nodes.find { |node| node.is_a?(::Ox::Element) && node.value == 'metadata' }
    end

    def header
      @header ||= Header.new(element.header)
    end
  end
end
