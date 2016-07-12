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

> :sunglasses:: I'm glad you asked. The best reason is that **it helps to fetch a lot of data at once**, and by that it significantly improves performance.

## Examples
### Example 1: Another data store

Imagine the following context:

```ruby
  class User < ApplicationRecord
    include Integrative::Integrator

    integrates :user_flag
  end

  class UserFlag < SomeRedisObject
    include Integrative::Integrated

    attr_accessor :user_id
    attr_accessor :name

    def self.find(ids)
      # Have in mind it's a simplification.
      # `find` should return array of hashes
      # with (in this case) `name` and `user_id`
      # so you'd need to store hashes
      # and convert data accordingly
      @redis.mget(*ids)
    end
  end
```

Now let's say you would like to see the list of all users with their flags. Try this:

```ruby
  users = User.limit(1000).integrate(:user_flag).to_a
```

**the above code will call redis only once** and will fetch user_flag for all 1000 users,
so now you can access all the flags like this:

```ruby
  users.map { |user| user.user_flag.name }
```

### Example 2: Prefetching another Active Record model

You can use Integrative also when you want to eager-load certain models to collection of other models when `ActiveRecord` doesn't make it easy.
Let's say you have the following situation:

```ruby
  class User < ApplicationRecord
    include Integrative::Integrator

    integrates :relation, requires: [:with]
  end

  class Relation
    include Integrative::Integrated

    def self.integrative_find(ids, integration)
      Relation.where(user_id: integration.call_options[:with].id, other_user_id: ids)
    end
  end
```
Now you want to fetch some Users and have already prefatched information about their relation with the current user.

With `Integrative` you just do:

```ruby
  User.where(public: true).integrate(:relation, with: current_user).limit(1000)
```

Boom. Pretty cool, ha?

## Treating integrated object as primary type value (string, int, ...)

Now check this out:

```ruby
  class User < ApplicationRecord
    integrates :is_admin, as: :primary
  end

  User.integrate(:is_admin).first.is_admin # that would be `true` or `false`
```

Of course for that you'd need to take care for preparing data properly in the integrated object:

```ruby
  class IsAdmin
    include Integrative::Integrated

    def self.integrative_find(ids, integration)
      # this should return a list of hashes
      # with a key (e.g. user_id) and a `value`,
      # for example:
      # [
      #   {user_id: 1, value: true}
      #   {user_id: 2, value: false}
      # ]
      response = find(ids)
      response.map { |item| OpenStruct.new(item) }
    end
  end
```

## Integrating objects with `1-to-many` relation

Like with `has_one` and `has_many` relations, sometimes you want to assign one external object
per model, but sometimes you want to assign an array of external objects per model. In such moments use `array: true` as an option parameter of integration

```ruby
  class User < ApplicationRecord
    integrates :flags, array: true
  end

  User.first.flags # this is an array
```

## Using `Integrative` on a single instance

So what if you'd like to prefetch something not for a list of users, but for a single user?
Well, it works exactly how you would think:

```ruby
  user = User.first
  user.flags # yes, that's gonna fetch and return a list of flags of the user.
```

## Using `Integrative` on an array

Sometimes you just want to prefetch certain data for an array of objects (and not for `ActiveRecord::Relation`). In such case just do:

```ruby
   users_with_flags = Integrative.integrate_into(users, :user_flags)
```

## Working with external resources

While working with external resources you need to implement the code that fetches external data and then assigns parts of it to the right models. Now it's all up to you how you'll do this but there is a pattern that fits well into `Integrative`. Take a look:

```ruby
  # file app/models/integrative_record.rb
  class IntegrativeRecord
    include Integrative::Integrated

    def url_base
      'http://external.service.com'
    end

    def full_url(ids)
      url_base + path(ids)
    end
  end

  # file app/models/avatar.rb
  class Avatar < IntegrativeRecord

    def path(ids)
      "avatars?user_ids=#{ids.join(',')}"
    end

    def find(ids)
      response = RestClient.get full_path(ids)
      response_hash = HashWithIndifferentAccess.new(JSON.parse(response.body))
      response_hash[:results]
    end
  end
```

## Contributing

If you feel like contributing to this project, feel free to create a bug report or send a pull request, but if you want to increase chances that I'll find time for taking care for your contribution, please make sure to make it easy for me - for pull requests write tests, for bug reports attach code that will let me reproduce the issue.

Have fun ;-)
