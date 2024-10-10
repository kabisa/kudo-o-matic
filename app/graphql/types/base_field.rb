class Types::BaseField < GraphQL::Schema::Field

  def authorized?(obj, args, ctx)
    if (owner && owner.respond_to?(:type_class)) 
      # Field specific policy
      policy = Util::GraphqlPolicy.guard(owner, name.to_sym)
      if policy
        authorized = policy.call(obj, args, ctx)
        raise GraphQL::ExecutionError.new("Not authorized to access #{owner.graphql_name}.#{name}") unless authorized
      end

      # Object type generic policy
      policy = Util::GraphqlPolicy.guard(owner, :'*')
      if policy
        authorized = policy.call(obj, args, ctx)
        raise GraphQL::ExecutionError.new("Not authorized to access #{owner.graphql_name}.#{name}") unless authorized
      end
    end

    super
  end

end