# -*- ruby -*-
#encoding: utf-8

require 'loggability'

require 'chione' unless defined?( Chione )


# An Assemblage mixin for defining factories for commmon entity configurations.
module Chione::Assemblage
	extend Loggability

	# Loggability API -- log to the chione logger
	log_to :chione


	### Extension callback -- add assemblage functionality to an extended +object+.
	def self::extended( object )
		super
		object.extend( Loggability )
		object.log_to( :chione )
		object.components ||= {}
	end


	### Inclusion callback -- add the components from this assemblage to those in
	### the specified +mod+.
	def included( mod )
		super
		self.log.debug "Including %d components in %p" % [ self.components.length, mod ]
		self.components.each do |component_type, args|
			self.log.debug "Adding %p to %p from %p" % [ component_type, mod, self ]
			mod.add( component_type, *args )
		end
	end


	##
	# The Hash of component types and initialization values to add to entities
	# constructed by this Assemblage.
	attr_accessor :components


	### Add a +component_type+ to the list used when constructing a new entity from
	### the current Assemblage. The component will be instantiated using the specified
	### +init_args+.
	def add( component_type, *init_args )
		self.components[ component_type ] = init_args
	end


	### Construct a new entity for the specified +world+ with all of the assemblage's
	### components.
	def construct_for( world )
		entity = world.create_entity
		self.components.each do |component_type, args|
			component = component_type.new( *args )
			entity.add_component( component )
		end

		return entity
	end

end # module Chione::Assemblage
