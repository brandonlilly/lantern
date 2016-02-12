class Store
  attr_accessor :index

  def initialize(options = {})
    self.index = options[:index] || 0
  end

  def allocateId
    id = index
    increment
    id
  end

  private

  def increment
    self.index += 1
  end
end

module StoreId
  module InstanceMethods
    attr_accessor :id, :store

    def initialize_store(options, class_store = nil)
      self.store =    options[:store] || class_store
      self.id =       options[:id] || allocateId
    end

    def allocateId
      store.allocateId
    end
  end

  def self.included(receiver)
    receiver.send :include, InstanceMethods
  end
end
