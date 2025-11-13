# FastAPI Template

Template repository for all FastAPI backend projects developed by Omukk.

## Components
- Basic FastAPI dependencies
- Docker and Docker Compose for easier testing
- Alembic configuration for database migrations
- Initial codebase to start from

## Using this template

1. **Create a new repository from this template**:
   - Navigate to [this repository](https://github.com/R3dRum92/FastAPI-Template.git)
   - Click the "Use this template" button at the top of the page
   - Choose "Create a new repository"
   - Fill in your new repository details and click "Create Repository"

2. **Clone your new repository**:
   ```bash
   git clone https://github.com/R3dRum92/FastAPI-Template.git
   cd <repo>
   ```

## Development and Testing

1. **Install dependencies**:
   ```
   poetry install
   poetry run pre-commit install
   ```
2. **Run database server**:
   ```bash
   docker compose up db -d
   ```
3. **Run Dev Server**:
   ```bash
   poetry run fastapi dev
   ```

4. **Stop Database Server**:
   ```bash
   docker compose down db
   ```

## Development Rules
- Create a separate branch from `dev` and create a PR to `dev` after making changes
- Branch names must be meaningful.
- Always run `black` and `isort` to maintain code consistency (this is done automatically using pre-commit hooks)-
   ```bash
   poetry run isort app main.py
   poetry run black app main.py
   # Make sure to run isort first
   ```

- Use static type checking using `mypy` if you feel like it (It is recommended but not mandatory). Static type checking might help you to identify critical bugs.
