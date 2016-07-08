**WARNING: Until version 0.1 some of the features described below might not be implemented yet.**

# Integrative

Integrative is a library for integrating external resources into ActiveRecord models.

Now, however you interpret "external" - this library is exactly for that ;-)

Cosider few exaples of what can be integrated into ActiveRecord model:
* ActiveResource model
* a custom object that fetches data from external websites
* an object fetching data from Redis
* another ActiveRecord model

You may ask

> :triumph:: ok, but why would I use Integrative? I can easily implement that on my own.

&nbsp;

> :sunglasses:: I'm glad you asked. The best reason is that **it helps fetch a lot of data at once**, and by that it significantly improves performance.

## Examples
### Example 1: Another data store

Imagine the following context:

```ruby
  class User < ApplicationRecord
    integrates :user_flags
  end

  class UserFlag < SomeRedisObject
    attr_accessor :user_id
    attr_accessor :flags_list

    def extract_ids(objects)
      objects.map { |obj| "redis_user_flag_#{obj.id}" }
    end

    def self.fetch(ids)
      @redis.mget(*ids)
    end
  end
```

Now let's say you would like to see the list of all users with their flags. Try this:

```ruby
  users = User.limit(1000).integrate(:user_flags).to_a
```

**the above code will call redis only once** and will fetch user_flag for all 1000 users,
so now you can access all the flags like this:

```ruby
  users.map { |user| user.user_flag }
```

### Example 2: Prefetching another Active Record model

You can use Integrative also when you want to eager-load certain models to collection of other models when `ActiveRecord` doesn't make it easy.
Let's say you have the following situation:

```ruby
  class User < ApplicationRecord
    integrates :relation_with_current_user, as: :boolean
  end

  class RelationWithCurrentUser < SomeRedisObject
    def self.fetch(ids, options)
      relations = Relation.where(user_id: options[:user].id, other_user_id: ids)
      hash_by_id(relations, :user_id)
    end
  end
```
Now you want to fetch some Users and have already prefatched information about their relation with the current user.

With `Integrative` you just do:

```ruby
  User.where(public: true).integrate(:relation_with_current_user, user: current_user).limit(1000)
```

Boom. Pretty cool, ha?

## Using `Integrative` on a single object

So what if you'd like to prefetch something not for a list of users, but for a sibgle user?
Well, it works exactly how you would think:

```ruby
  fun = User.first
  fun.with_flags # yes, that's gonna fetch and return a list of flags of the user.
```

## Using `Integrative` on an array

Sometimes you just want to prefetch certain data for an array of objects (and not for `ActiveRecord::Relation`). In such case just do:

```ruby
   users_with_flags = Integrative.integrate_into(users, :user_flags)
```

## Working with external resources

`Integrative` just works if what you want to integrate into a model is an `ActiveRecord` object. All you have to do is to include the right module:

```ruby
  class PrefetchedResource < ApplicationRecord
    include Integrative::ActiveRecord
  end
```

but when you want to work with external resources you would need to implement the code that actually fetches external data and then iterates over the result to assign parts of it to the right models. `Integrative` offers a pattern for that. Take a look.

```ruby
  # file app/models/integrative_record.rb
  class IntegrativeRecord < Integrative::ExternalResource
  end

  # file app/models/external_resource.rb
  class ExternalResource < IntegrativeRecord
    def integrative_find(objects, options = {})
      # Some fetching and putting things into objects
    end
  end
```
