module Mutations
  class BaseMutation < GraphQL::Schema::Mutation
    # methods that should be inherited can go here.
    # like a `current_tenant` method, or methods related
    # to the `context` object

    def authorized?(**args)
      # implement your authorization logic here
      # this method should return `true` if the user is authorized, and `false` if they are not
      # it should return `true` by default

      type = "Mutation"
      policy = Util::GraphqlPolicy.guard(self.field.owner, self.field)
      return true if policy.nil?
      authorized = policy.call(self.object, args, self.context)
      
      raise GraphQL::ExecutionError.new("Not authorized to access #{type}.#{field.name}") unless authorized
      true
    end
  end
end