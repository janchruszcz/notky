# notky

![Screenshot](/docs/ss1.png)

## About

notky is a simple sticky notes/corkboard-like todo app. It was designed for personal use and built with Ruby on Rails with Hotwire.

## Prerequisites

Before getting started, make sure you have the following installed:

- Ruby version 3.2.2
- Rails version 7.1.3.4
- SQLite3

## Installation

1. Clone the repository:

    ```shell
    git clone https://github.com/janchruszcz/notky.git
    ```

2. Install the required gems:

    ```shell
    bundle install
    ```

3. Set up the database:

    ```shell
    rails db:create
    rails db:migrate
    ```

## Usage

To start the application, run the following command:

```shell
./bin/dev
```

Open your web browser and visit `http://localhost:3000` to access the app.

## Features

- Create, edit, and delete sticky notes
- Drag and drop functionality for organizing notes
- Real-time updates using Hotwire

## License

This project is licensed under the [MIT License](link-to-license-file).
