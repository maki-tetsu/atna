# coding: utf-8
module ATNA
  module Utils
    module XmlBuilder
      class Base
        def self.attributes(*names)
          self.instance_eval do
            @attribute_names ||= []
            names.each do |name|
              @attribute_names << name.to_s.to_sym
            end

            next @attribute_names.dup
          end
        end

        def self.children_order(*klasses)
          self.instance_eval do
            @children ||= []
            klasses.each do |klass|
              raise "Unkown Element class [#{klass}]" unless self.node_class.include?(klass)
              @children << klass
            end

            next @children.dup
          end
        end

        def self.valid_attribute?(name)
          attributes.include?(name.to_s.to_sym)
        end

        def self.node_class(string = false)
          classes = self.constants.map { |c|
            if eval("::#{self.name}::#{c}.kind_of?(Class)")
              next eval("::#{self.name}::#{c} < ATNA::Utils::XmlBuilder::Base ? ::#{self.name}::#{c} : nil")
            end
            next nil
          }.compact
          classes.map! { |c| c.name.split("::").pop.to_s } if string

          return classes
        end

        def self.find_element_class(node_name)
          unless idx = node_class(true).index(node_name)
            raise "Unknown Element [#{node_name}]"
          end

          return node_class[idx]
        end

        def initialize(values = { })
          @children = []
          @attributes = self.class.attributes.inject({ }) { |h,n| h[n] = nil; next h }

          values.each do |key, value|
            case key
            when Symbol # Attribute
              if self.class.valid_attribute?(key)
                @attributes[key] = value # TODO value class check
              else
                raise "Unknown attribute [#{key}]"
              end
            when String # Element
              element_class = self.class.find_element_class(key)

              case value
              when Array
                value.each do |v|
                  add_child(element_class.new(v))
                end
              when Hash
                add_child(element_class.new(value))
              end
            else
              raise "Unknown key [#{key.inspect}]"
            end
          end
        end

        # Add children(element)
        def <<(element)
          @children << element

          return self
        end

        alias_method :add_child, :<<

          # Convert XML
          #
          # xml ::
          def to_xml(xml = nil)
            if xml
              build_xml(xml)
              return
            else
              builder = Nokogiri::XML::Builder.new(:encoding => "UTF-8") do |xml|
                build_xml(xml)
              end

              return builder.doc.to_xml
            end
          end

          def element_name
            self.class.name.split("::").last.to_sym
          end

          def sorted_children
            children_order = self.class.children_order
            @children.sort do |a,b|
              children_order.index(a.class) <=> children_order.index(b.class)
            end
          end

          # Build xml by Nokogiri
          def build_xml(xml)
            xml.send(element_name, attributes) do
              sorted_children.each do |element|
                element.to_xml(xml)
              end
            end
          end
          private :build_xml

          # Delete nil attributes on copy
          def attributes
            @attributes.dup.delete_if { |k,v| v.nil? }
          end
          private :attributes
        end
      end
    end
  end
