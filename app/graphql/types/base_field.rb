class Types::BaseField < GraphQL::Schema::Field
  def initialize(*args, **kwargs, &block)
    
    # If the field has a :resolve key,
    # add a custom resolver to the field owner, executing the provided Proc.
    if kwargs[:resolve]
      resolver_name = "resolve_#{kwargs[:name]}".to_sym
      kwargs[:resolver_method] = resolver_name

      kwargs[:owner].send(:define_method, resolver_name) do
        kwargs[:resolve].call(object, args, context)
      end
    end

    super(*args, **kwargs, &block)
  end

  # Authorisation policy model, based on GraphQL-Guard gem. Uses Util::GraphqlPolicy for policy definitions.
  def authorized?(obj, args, ctx)
    if (owner && owner.respond_to?(:type_class)) 
      # Field specific policy
      policy = Util::GraphqlPolicy.guard(owner, name.to_sym)
      if policy
        authorized = policy.call(obj, args, ctx)
        raise GraphQL::ExecutionError.new("Not authorized to access #{owner.graphql_name}.#{name}") unless authorized
      else
        # Object type generic policy
        policy = Util::GraphqlPolicy.guard(owner, :'*')
        if policy
          authorized = policy.call(obj, args, ctx)
          raise GraphQL::ExecutionError.new("Not authorized to access #{owner.graphql_name}.#{name}") unless authorized
        end
      end
    end

    super
  end

end