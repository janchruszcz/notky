# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Notky is a digital corkboard task management app built with Ruby on Rails 7.1 and Hotwire. Users can create sticky-note style lists with draggable, reorderable todos.

See `docs/MODERNIZATION_PLAN.md` for a comprehensive 7-phase refactoring roadmap.

## Development Commands

```bash
# Start development server (Rails + Tailwind CSS watcher)
./bin/dev

# Run full test suite
bundle exec rspec

# Run a single test file
bundle exec rspec spec/features/dashboard_spec.rb

# Run a specific test by line number
bundle exec rspec spec/requests/lists_spec.rb:25

# Linting and security
bundle exec rubocop                    # Ruby style linting
bundle exec rubocop -A                 # Auto-fix
bundle exec erblint --lint-all         # ERB template linting
bundle exec brakeman -q                # Security vulnerability scan

# Database
rails db:create db:migrate             # Setup database
rails db:reset                         # Drop, create, migrate, seed

# Tailwind CSS
rails tailwindcss:build                # One-time build
rails tailwindcss:watch                # Watch for changes (runs via ./bin/dev)
```

## Architecture

### Tech Stack
- **Backend:** Rails 7.1, SQLite3, Devise (auth)
- **Frontend:** Hotwire (Turbo + Stimulus), Tailwind CSS, SortableJS
- **Testing:** RSpec, Capybara, FactoryBot, Selenium (headless Chrome)

### Data Model
```
User (Devise auth)
  └── has_many Lists (row_order for drag-drop sorting)
        └── has_many Todos (row_order scoped to list_id)
```

Drag-and-drop ordering uses `ranked-model` gem with `row_order` columns.

### Hotwire Patterns

All CRUD operations use **Turbo Streams** for real-time UI updates without full page reloads:
- Controllers respond with `format.turbo_stream`
- Views use `turbo_stream.append`, `turbo_stream.replace`, `turbo_stream.remove`
- Modals use Turbo Frames (`turbo_frame_tag "modal"`)

### Stimulus Controllers (`app/javascript/controllers/`)

| Controller | Purpose |
|------------|---------|
| `sortable_controller.js` | Drag-drop reordering via SortableJS, PUTs to `/lists/:id/sort` or `/todos/:id/sort` |
| `todos_controller.js` | Todo completion toggle with strikethrough |
| `turbo_modal_controller.js` | Modal open/close, ESC key handling |
| `auto_submit_controller.js` | Auto-submit forms on input change |
| `inline_edit_controller.js` | Focus input fields on Turbo Frame load |
| `alert_controller.js` | Auto-dismiss flash messages |
| `date_picker_controller.js` | Flatpickr date picker integration |

### Routes Structure

```ruby
root 'dashboard#index'           # Main corkboard view
resources :lists                 # CRUD + PUT :sort (member)
resources :todos                 # CRUD + PUT :sort (member)
devise_for :users                # Authentication
```

### Key Conventions

- All controllers require authentication (via `ApplicationController`)
- User data isolation: always scope queries through `current_user.lists`
- Turbo Stream responses for all mutations (no JSON APIs)
- `row_order_position` param triggers ranked-model reordering
- Todos can move between lists via sort endpoint (`list_id` + `row_order_position`)

## Current State & Known Limitations

| Area | Status | Notes |
|------|--------|-------|
| Backend | Good | Rails 7.1, Hotwire working well |
| Mobile | Limited | Fixed 3-column grid, needs responsive breakpoints |
| Accessibility | Basic | Some axe-core tests, needs WCAG 2.1 AA work |
| Testing | ~50% coverage | Gaps in validation tests, system tests |
| Database | SQLite | Works for dev, PostgreSQL recommended for production |

**Current UI issues:**
- No model validations (commented out in specs)
- Controllers lack explicit authorization checks (relies on association scoping)
- No input sanitization beyond Rails defaults

## Planned Architectural Improvements

When refactoring, follow these patterns from the modernization plan:

**Service Objects** (`app/services/`):
```ruby
# Pattern: Extract complex controller logic
module Lists
  class ReorderService
    def initialize(user:, list_id:, position:)
    def call
      # Returns Result struct with success/error
    end
  end
end
```

**ViewComponents** (`app/components/`):
- Prefer over partials for reusable UI (ListComponent, TodoComponent, ModalComponent)
- Add via `bundle add view_component`

**Form Objects** (`app/forms/`):
- Use for complex validation (TodoForm with title length, due_date validation)

## Commit Conventions

Use conventional commits:
```
<type>(<scope>): <description>
```

**Types:** `feat`, `fix`, `refactor`, `perf`, `test`, `docs`, `chore`, `ci`, `security`, `devops`

**Examples:**
```bash
git commit -m "feat: add list color customization"
git commit -m "refactor: extract service objects for business logic"
git commit -m "perf: add database indexes for common queries"
```

## Future Tech Stack (per modernization plan)

| Current | Target | Rationale |
|---------|--------|-----------|
| SQLite | PostgreSQL | Production-ready, concurrent writes |
| No caching | Redis | Fragment caching, Action Cable |
| No jobs | Solid Queue | Background processing (Rails 8 default) |
| Basic CSS | Tailwind + animations | Modern micro-interactions |
| 3-col grid | Responsive 1-5 cols | Mobile-first design |
