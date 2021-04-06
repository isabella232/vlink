# vlink
vLink - Create simple, easy to remember links

# Overview
URLs can be unwieldy. Typing `https://docs.random.io/document/d/sldfjdslfosfskdjflsdfjlsfjlksdjflsdfslkdfjlsdjf-dfksjdflsjflsjlf/edit#heading=dfksjdlfsjl`
is an exercise in futility. You could bookmark it. But what if you use multiple browsers?

URL shorteners don't solve this problem, either. While they create shorter links, they aren't any easier to remember.

With vLink, you can create custom links. For example, the vLink to the doc above could be
[https://vlink.example.com/network-pm](https://vlink.example.com/network-pm).

# Design
The design for vLink is simple. Create a link that points to another (longer) link. That's it!

It borrows (maybe steals?) from Unix's concept of symbolic links. (OK, if you're from the
Windows or Mac worlds, it's similar to a shortcut.)

## Tech Stack

- [Sinatra](http://www.sinatrarb.com)
- [DataMapper](http://datamapper.org/)
- [Postgres](https://www.postgresql.org/)
- [Ruby](https://www.ruby-lang.org/en/)

# Deployment
vLink runs on Flynn. To deploy it, follow these steps.

## Step 0 Install the [Flynn CLI](https://github.com/flynn/flynn) and configure it to access the development cluster

## Step 1 Check out the source code
```
> git clone https://github.com/Vestorly/vlink.git
```

## Step 2 Push
```
> git push flynn master
```
