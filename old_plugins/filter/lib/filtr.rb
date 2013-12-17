# Filter let you specify common filtering options, in order to generate
# a filtered condition, useful for filtering from request params.
#
# Example usage:
#   @filter = Filter.new
#   @filter.multiple :types, "type_id"
#
#   @people = People.find(:all, :conditions => @filter.conditions)
#
#   # Generates: SELECT * FROM people WHERE (type_id IN (1,2))

# (2013) Modified by Benjamin Ninassi for rails 3.2 compatibility
class Filtr
  class Engine < Rails::Engine
    initializer "filtr" do
      
    end
    config.autoload_paths << File.expand_path("..", __FILE__)
    
  end
  # Instantiate a new filter using the data hash as base.
  def initialize
    @filters = Array.new
    @filters << [" 1=1 "]
  end

  # Defines a filtering that accepts multiple values.
  # This will match against the filtered column looking for ANY of the values in the key.
  #
  # Example:
  #   # This will match all the objects that have type_id = 1 OR type_id = 2
  #   @filter = Filter.new
  #   @filter.multiple :types, 'type_id'
  def multiple(key, filtered, association = "AND", add = "")
    key = key
    @filters << [" #{association} #{filtered} IN (?) #{add}", key] unless key.nil? || key.empty?
  end

  def not_multiple(key, filtered, association = "AND", add = "")
    key = key
    @filters << [" #{association} #{filtered} NOT IN (?) #{add}", key] unless key.nil? || key.empty?
  end

  # Defines a filtering that checks for equality.
  #
  # Example:
  #   @filter = Filter.new
  #   @filter.equal params[:id], 'an_id'
  def equal(key, filtered, association = "AND", add = "")
    key = key.to_s
    @filters << [" #{association} #{filtered} = ? #{add}", key] unless key.nil? || key.empty?
  end

  def not_equal(key, filtered, association = "AND", add = "")
    key = key.to_s
    @filters << [" #{association} #{filtered} != ? #{add}", key] unless key.nil? || key.empty?
  end

  def is_null(filtered, association = "AND", add = "")
    @filters << [" #{association} #{filtered} IS NULL #{add}"]
  end

  def is_not_null(filtered, association = "AND", add = "")
    @filters << [" #{association} #{filtered} IS NOT NULL #{add}"]
  end

  # Defines a filtering that checks for great.
  #
  # Example:
  #   @filter = Filter.new
  #   @filter.great :other_id, 'an_id'
  def great(key, filtered, association = "AND", add = "")
    key = key.to_s
    @filters << [" #{association} #{filtered} >= ? #{add}", key] unless key.nil? || key.empty?
  end

  # Defines a filtering that checks for less.
  #
  # Example:
  #   @filter = Filter.new
  #   @filter.less :other_id, 'an_id'
  def less(key, filtered, association = "AND", add = "")
    key = key.to_s
    @filters << [" #{association} #{filtered} <= ? #{add}", key] unless key.nil? || key.empty?
  end

  def est(key, filtered, association = "AND", add = "")
    key = key.to_s
    @filters << [" #{association} #{filtered} LIKE ? #{add}", key] unless key.nil? || key.empty?
  end

  def n_est_pas(key, filtered, association = "AND", add = "")
    key = key.to_s
    @filters << [" #{association} #{filtered} NOT LIKE ? #{add}", key] unless key.nil? || key.empty?
  end

  def contient(key, filtered, association = "AND", add = "")
    key = "%"+key.to_s+"%"
    @filters << [" #{association} #{filtered} LIKE ? #{add}", key] unless key.nil? || key.empty?
  end

  def ne_contient_pas(key, filtered, association = "AND", add = "")
    key = "%"+key.to_s+"%"
    @filters << [" #{association} #{filtered} NOT LIKE ? #{add}", key] unless key.nil? || key.empty?
  end

  def commence_par(key, filtered, association = "AND", add = "")
    key = key.to_s+"%"
    @filters << [" #{association} #{filtered} LIKE ? #{add}", key] unless key.nil? || key.empty?
  end

  def se_termine_par(key, filtered, association = "AND", add = "")
    key = "%"+key.to_s
    @filters << [" #{association} #{filtered} LIKE ? #{add}", key] unless key.nil? || key.empty?
  end


  def like(key, filtered, association = "AND", add = "")
    key = key.to_s+"%"
    @filters << [" #{association} #{filtered} LIKE ? #{add}", key] unless key.nil? || key.empty?
  end

  # Generate an ActiveRecord prepared condition using the specified filters.
  # Used to scope the query.
  #
  # Example:
  #   People.find(:all, :conditions => @filter.conditions)
  #
  # If the filter is empty, this method will return nil, which will be ignored by AR.
  def conditions
    unless self.empty?
      @filters.inject([""]) do |condition,filter|
        filter = filter.dup
    #     condition.first << " AND " unless condition.first.empty?
        condition.first << filter.shift
        condition += filter
      end
    end
  end

  # Returns true or false for whether this filter is empty or not.
  #
  # Example:
  #   @filter = Filter.new nil
  #   @filter.empty?  # => true
  #
  #   @filter = Filter.new {}
  #   @filter.empty?  # => true
  #
  #   @filter = Filter.new :foo => 'bar'
  #   @filter.empty?  # => false
  def empty?
    @filters.nil? or @filters.empty?
  end
end
