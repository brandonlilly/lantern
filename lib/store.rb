class Store
  attr_accessor :size, :availableIds

  def initialize(options = {})
    @size = options[:size]
    @availableIds = Array.new(size, false)
  end

  def remove(id)
    set_id(id, :used)
  end

  def allocateTempId
    id = getAvailableId
    set_id(id, true)
    id
  end

  def allocateId
    id = getUnusedId
    set_id(id, true)
    id
  end

  private

  def set_id(id, value)
    availableIds[id] = value
  end

  def getUnusedId
    availableIds.size.times do |i|
      return i if availableIds[i] == false
    end

    raise "No unused switches."
  end

  def getAvailableId
    availableIds.size.times do |i|
      return i if availableIds[i] == false || availableIds[i] == :used
    end

    raise "No available switches."
  end
end

module StoreId
  module InstanceMethods
    @@store = Store.new(size: 256)

    attr_accessor :id, :implicit, :store

    def initialize_store(options)
      self.store =    options[:store] || @@store
      self.implicit = options.fetch(:implicit, false)
      self.id =       options[:id] || allocateId
    end

    def destroy
      raise "Can only destroy temporary objects" unless implicit
      self.class.finalize(store, id).call()
      ObjectSpace.undefine_finalizer(self)
      self.id = nil
    end

    def allocateId
      if implicit
        new_id = store.allocateTempId
        ObjectSpace.define_finalizer(self, self.class.finalize(store, new_id))
        return new_id
      end

      store.allocateId
    end
  end

  module ClassMethods
    def finalize(store, id)
      proc do
        store.remove(id)
      end
    end

    def temp(options = {})
      new(options.merge(
        implicit: true
      ))
    end
  end

  def self.included(receiver)
    receiver.extend         ClassMethods
    receiver.send :include, InstanceMethods
  end
end
