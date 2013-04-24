require 'ox'

module XmlHasher
  class Handler < ::Ox::Sax
    def initialize(options = {})
      @options = options
      @stack = []
    end

    def to_hash
      @hash || {}
    end

    def start_element(name)
      @stack.push(Node.new(transform(name)))
    end

    def attr(name, value)
      unless ignore_attribute?(name)
        @stack.last.attributes[transform(name)] = value unless @stack.empty?
      end
    end

    def text(value)
      @stack.last.text = value
    end

    def end_element(name)
      if @stack.size == 1
        @hash = @stack.pop.to_hash
      else
        node = @stack.pop
        @stack.last.children << node
      end
    end

    private

    def transform(name)
      name = name.to_s.split(':').last if @options[:ignore_namespaces]
      name = Util.snakecase(name) if @options[:snakecase]
      name
    end

    def ignore_attribute?(name)
      @options[:ignore_namespaces] ? !name.to_s[/^(xmlns|xsi)/].nil? : false
    end
  end
end
