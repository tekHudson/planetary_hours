# README

This README would normally document whatever steps are necessary to get the
application up and running.

Things you may want to cover:

* Ruby version

* System dependencies

* Configuration

* Database creation

* Database initialization

* How to run the test suite

* Services (job queues, cache servers, search engines, etc.)

* Deployment instructions

* ...

## Environment Variables

This application uses environment variables for configuration. Create a `.env` file in the root directory with the following variables:

```bash
# Copy the example file
cp .env.example .env

# Edit the .env file with your values
```

### Required Variables

- `DATABASE_URL`: PostgreSQL connection string
- `SECRET_KEY_BASE`: Rails secret key (generate with `rails secret`)
- `POSTGRES_DB`: Database name
- `POSTGRES_USER`: Database user
- `POSTGRES_PASSWORD`: Database password

### Security Note

The `.env` file is ignored by git and should never be committed to version control. Use `.env.example` as a template for other developers.

