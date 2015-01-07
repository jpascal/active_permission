# ActivePermission

This gem allow you load and authorize resource in Ruby on Rails inside controllers or views using Ability class with described abilities of user.

## Installation

Add this line to your application's Gemfile:

```
gem 'activepermission'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install activepermission

## Usage

### Define Abilities

Add a new class in `app/models/ability.rb` with the following contents:

```
class Ability < ActivePermission::Ability
  def initialize(user = nil)
  end
end
```

### Load Resource

```
class BooksController < ApplicationController
  resource :book, object: 'Book'
end
```

```
class BooksController < ApplicationController
  resource :book do
    Book.find(params[:id])
  end
end
```

### Authorization

```
class BooksController < ApplicationController
  authorize :book
end
```

```
class BooksController < ApplicationController
  def show
    @book = Book.find(params[:id])
    authorize! @book
  end
  def destroy
    @book = Book.find(params[:id])
    if authorize @book, :destroy
      @book.destroy
    else
      flash[:warning] = 'Can't delete book'
    end
  end
end
```

### Check Abilities

```
<% if can? 'books', 'show', @book %>
  <%= render 'book', book: @book %>
<% end %>
```

```
<% if can? 'books', ['edit', 'update'], @book %>
  <%= render 'links', book: @book %>
<% end %>
```


## Contributing

1. Fork it ( https://github.com/[my-github-username]/activepermission/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create a new Pull Request
