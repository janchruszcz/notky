# Notky Modernization Plan

> A comprehensive, agentic refactoring guide to fully modernize Notky - the digital corkboard task management app.

**Current Stack:** Ruby 3.2.2 | Rails 7.1.3.4 | Hotwire (Turbo + Stimulus) | Tailwind CSS | SQLite3

---

## Table of Contents

1. [Executive Summary](#1-executive-summary)
2. [Phase 1: Foundation & Code Quality](#2-phase-1-foundation--code-quality)
3. [Phase 2: Database & Performance](#3-phase-2-database--performance)
4. [Phase 3: UI/UX Modernization](#4-phase-3-uiux-modernization)
5. [Phase 4: Feature Enhancements](#5-phase-4-feature-enhancements)
6. [Phase 5: Testing & CI/CD](#6-phase-5-testing--cicd)
7. [Phase 6: Security Hardening](#7-phase-6-security-hardening)
8. [Phase 7: Deployment & DevOps](#8-phase-7-deployment--devops)
9. [Appendix: Commit Strategy](#9-appendix-commit-strategy)

---

## 1. Executive Summary

### Current State Assessment

| Area | Status | Priority |
|------|--------|----------|
| Backend Architecture | Good (Rails 7.1, Hotwire) | Medium |
| Frontend/UI | Functional but dated | High |
| Mobile Responsiveness | Limited (3-column grid only) | Critical |
| Accessibility | Basic (some axe-core tests) | High |
| Testing | Good foundation, gaps exist | Medium |
| Performance | Untested at scale | Medium |
| Security | Good (Devise, CSP) | Low |
| Documentation | Minimal | Medium |

### Modernization Goals

1. **Mobile-First Responsive Design** - Full PWA capabilities
2. **Enhanced UX** - Animations, better feedback, keyboard shortcuts
3. **Improved Accessibility** - WCAG 2.1 AA compliance
4. **Performance Optimization** - Sub-200ms response times
5. **Comprehensive Testing** - 90%+ coverage with E2E tests
6. **Production Readiness** - PostgreSQL, Redis, proper caching

---

## 2. Phase 1: Foundation & Code Quality

### 2.1 Dependency Updates

**Action Items:**

```bash
# Update Ruby (if not constrained)
# Current: 3.2.2 → Target: 3.3.x (latest stable)

# Update Gemfile dependencies
bundle update --conservative
```

**Gems to Update/Add:**

| Gem | Current | Target | Purpose |
|-----|---------|--------|---------|
| `ruby` | 3.2.2 | 3.3.x | Latest Ruby features |
| `rails` | 7.1.3.4 | 7.2.x | Latest Rails (when stable) |
| `tailwindcss-rails` | 2.6 | 3.x | Tailwind v4 support |
| `solid_queue` | - | Add | Background jobs (Rails 8 default) |
| `mission_control-jobs` | - | Add | Job monitoring dashboard |
| `propshaft` | - | Consider | Modern asset pipeline |

**Commit:** `chore: update dependencies to latest stable versions`

---

### 2.2 Code Structure Refactoring

#### 2.2.1 Extract Service Objects

**Current:** Business logic in controllers
**Target:** Service objects for complex operations

```ruby
# app/services/lists/reorder_service.rb
module Lists
  class ReorderService
    def initialize(user:, list_id:, position:)
      @user = user
      @list_id = list_id
      @position = position
    end

    def call
      list = @user.lists.find(@list_id)
      list.update!(row_order_position: @position)
      Result.new(success: true, list: list)
    rescue ActiveRecord::RecordNotFound
      Result.new(success: false, error: "List not found")
    end

    Result = Struct.new(:success, :list, :error, keyword_init: true)
  end
end
```

**Files to Create:**
- [ ] `app/services/base_service.rb`
- [ ] `app/services/lists/create_service.rb`
- [ ] `app/services/lists/reorder_service.rb`
- [ ] `app/services/todos/create_service.rb`
- [ ] `app/services/todos/toggle_completion_service.rb`

**Commit:** `refactor: extract service objects for business logic`

---

#### 2.2.2 Add View Components

**Current:** ERB partials with Turbo Streams
**Target:** ViewComponent for reusable UI components

```bash
bundle add view_component
rails generate component List list
rails generate component Todo todo
rails generate component Modal title
```

**Components to Create:**
- [ ] `app/components/list_component.rb` + `.html.erb`
- [ ] `app/components/todo_component.rb` + `.html.erb`
- [ ] `app/components/modal_component.rb` + `.html.erb`
- [ ] `app/components/flash_message_component.rb` + `.html.erb`
- [ ] `app/components/empty_state_component.rb` + `.html.erb`

**Commit:** `refactor: introduce ViewComponent for UI components`

---

#### 2.2.3 Add Form Objects

**Target:** Dry-validation for complex form handling

```ruby
# app/forms/todo_form.rb
class TodoForm
  include ActiveModel::Model
  include ActiveModel::Attributes

  attribute :title, :string
  attribute :description, :string
  attribute :due_date, :datetime
  attribute :list_id, :integer

  validates :title, presence: true, length: { maximum: 255 }
  validates :description, length: { maximum: 1000 }
  validates :due_date, comparison: { greater_than: -> { Time.current } }, allow_nil: true
end
```

**Commit:** `refactor: add form objects for input validation`

---

### 2.3 Linting & Code Style

**Action Items:**

```bash
# Run existing linters
bundle exec rubocop -A
bundle exec erblint --lint-all -a
bundle exec brakeman -q

# Add new quality tools
bundle add standard --group development  # Modern Ruby style guide
bundle add reek --group development      # Code smell detection
```

**RuboCop Configuration Update:**

```yaml
# .rubocop.yml additions
require:
  - rubocop-rails
  - rubocop-rspec
  - rubocop-performance

AllCops:
  NewCops: enable
  TargetRubyVersion: 3.3

Style/Documentation:
  Enabled: false

Metrics/MethodLength:
  Max: 15

Metrics/BlockLength:
  Exclude:
    - 'spec/**/*'
    - 'config/routes.rb'
```

**Commit:** `chore: configure enhanced linting rules`

---

## 3. Phase 2: Database & Performance

### 3.1 Database Migration (SQLite → PostgreSQL)

**Rationale:** Production-ready, better concurrent writes, advanced features

**Action Items:**

```bash
# Add PostgreSQL gem
bundle add pg

# Update database.yml
```

```yaml
# config/database.yml
default: &default
  adapter: postgresql
  encoding: unicode
  pool: <%= ENV.fetch("RAILS_MAX_THREADS") { 5 } %>

development:
  <<: *default
  database: notky_development

test:
  <<: *default
  database: notky_test

production:
  <<: *default
  url: <%= ENV['DATABASE_URL'] %>
```

**Migration Script:**

```bash
# Export data from SQLite
rails db:seed:dump  # Or use pgloader

# Create PostgreSQL databases
rails db:create db:migrate

# Import data
rails db:seed
```

**Commit:** `feat: migrate from SQLite to PostgreSQL`

---

### 3.2 Add Database Indexes

**Current indexes:** Basic foreign keys only

**Add Performance Indexes:**

```ruby
# db/migrate/xxx_add_performance_indexes.rb
class AddPerformanceIndexes < ActiveRecord::Migration[7.1]
  def change
    # Composite index for user's lists ordering
    add_index :lists, [:user_id, :row_order], name: 'index_lists_on_user_and_order'

    # Composite index for list's todos ordering
    add_index :todos, [:list_id, :row_order], name: 'index_todos_on_list_and_order'

    # Index for filtering by completion status
    add_index :todos, [:list_id, :completed], name: 'index_todos_on_list_and_completed'

    # Index for due date queries
    add_index :todos, :due_date, where: 'due_date IS NOT NULL'
  end
end
```

**Commit:** `perf: add database indexes for common queries`

---

### 3.3 Implement Caching

**Action Items:**

```ruby
# config/environments/production.rb
config.cache_store = :redis_cache_store, {
  url: ENV['REDIS_URL'],
  namespace: 'notky_cache',
  expires_in: 1.hour
}

# Enable Russian Doll caching in views
config.action_controller.perform_caching = true
```

**Add Cache Keys to Models:**

```ruby
# app/models/list.rb
class List < ApplicationRecord
  # Touch parent for cache invalidation
  belongs_to :user, touch: true

  def cache_key_with_version
    "#{cache_key}-#{todos.maximum(:updated_at).to_i}"
  end
end
```

**Fragment Caching in Views:**

```erb
<%# app/views/lists/_list.html.erb %>
<% cache list do %>
  <div class="list-card" data-list-id="<%= list.id %>">
    <%= render list.todos.rank(:row_order) %>
  </div>
<% end %>
```

**Commit:** `perf: implement Redis caching with Russian Doll strategy`

---

### 3.4 Add Background Job Processing

**Replace inline operations with async jobs:**

```ruby
# app/jobs/send_due_date_reminder_job.rb
class SendDueDateReminderJob < ApplicationJob
  queue_as :default

  def perform(todo_id)
    todo = Todo.find(todo_id)
    return if todo.completed?

    # Send notification (email, push, etc.)
    TodoMailer.due_date_reminder(todo).deliver_later
  end
end
```

**Configure Solid Queue:**

```yaml
# config/solid_queue.yml
default: &default
  dispatchers:
    - polling_interval: 1
      batch_size: 500
  workers:
    - queues: "*"
      threads: 3
      processes: 1
      polling_interval: 0.1

production:
  <<: *default
```

**Commit:** `feat: add Solid Queue for background job processing`

---

## 4. Phase 3: UI/UX Modernization

### 4.1 Mobile-First Responsive Design

**Current:** Fixed 3-column grid (`grid-cols-3`)
**Target:** Responsive breakpoints with mobile-first approach

**Tailwind Configuration Update:**

```javascript
// tailwind.config.js
module.exports = {
  theme: {
    screens: {
      'sm': '640px',
      'md': '768px',
      'lg': '1024px',
      'xl': '1280px',
      '2xl': '1536px',
    },
    extend: {
      // Custom breakpoint for sticky note sizing
      spacing: {
        'note': '280px',
        'note-sm': '240px',
      }
    }
  }
}
```

**Responsive Grid Update:**

```erb
<%# app/views/dashboard/index.html.erb %>
<div class="
  grid gap-4 p-4
  grid-cols-1
  sm:grid-cols-2
  lg:grid-cols-3
  xl:grid-cols-4
  2xl:grid-cols-5
">
  <%= render @lists %>
</div>
```

**Mobile Navigation:**

```erb
<%# app/views/layouts/_navbar.html.erb %>
<nav class="sticky top-0 z-50 bg-white/80 backdrop-blur-md border-b">
  <div class="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
    <div class="flex justify-between h-16">
      <!-- Logo -->
      <div class="flex items-center">
        <span class="text-xl font-bold text-slate-800">Notky</span>
      </div>

      <!-- Mobile menu button -->
      <div class="flex items-center sm:hidden">
        <button data-controller="mobile-menu" data-action="click->mobile-menu#toggle">
          <svg class="h-6 w-6" fill="none" viewBox="0 0 24 24" stroke="currentColor">
            <path stroke-linecap="round" stroke-linejoin="round" stroke-width="2" d="M4 6h16M4 12h16M4 18h16" />
          </svg>
        </button>
      </div>

      <!-- Desktop menu -->
      <div class="hidden sm:flex sm:items-center sm:space-x-4">
        <%= render 'layouts/user_menu' %>
      </div>
    </div>
  </div>
</nav>
```

**Commit:** `feat: implement mobile-first responsive design`

---

### 4.2 Design System & Visual Refresh

#### 4.2.1 Color Palette Update

**Current:** Basic yellow sticky notes
**Target:** Modern, customizable color themes

```javascript
// tailwind.config.js
module.exports = {
  theme: {
    extend: {
      colors: {
        // Sticky note colors
        'note': {
          'yellow': '#FEF3C7',
          'pink': '#FCE7F3',
          'blue': '#DBEAFE',
          'green': '#D1FAE5',
          'purple': '#EDE9FE',
          'orange': '#FFEDD5',
        },
        // Primary brand colors
        'brand': {
          50: '#f0f9ff',
          100: '#e0f2fe',
          500: '#0ea5e9',
          600: '#0284c7',
          700: '#0369a1',
        }
      }
    }
  }
}
```

#### 4.2.2 Typography Scale

```css
/* app/assets/stylesheets/application.tailwind.css */
@layer base {
  h1 { @apply text-2xl sm:text-3xl font-bold text-slate-900; }
  h2 { @apply text-xl sm:text-2xl font-semibold text-slate-800; }
  h3 { @apply text-lg font-medium text-slate-700; }

  body {
    @apply antialiased text-slate-600;
    font-feature-settings: "cv02", "cv03", "cv04", "cv11";
  }
}
```

#### 4.2.3 Sticky Note Card Redesign

```erb
<%# app/views/lists/_list.html.erb %>
<div
  class="
    group relative
    bg-note-yellow
    rounded-lg shadow-lg
    hover:shadow-xl hover:-translate-y-1
    transition-all duration-200 ease-out
    p-4 min-h-[200px]
    before:absolute before:inset-0 before:bg-gradient-to-b
    before:from-white/20 before:to-transparent before:rounded-lg
  "
  data-controller="list"
  data-list-id="<%= list.id %>"
>
  <!-- Pin decoration -->
  <div class="absolute -top-2 left-1/2 -translate-x-1/2">
    <div class="w-4 h-4 rounded-full bg-red-500 shadow-md border-2 border-red-600"></div>
  </div>

  <!-- Header -->
  <header class="flex items-center justify-between mb-3 pt-2">
    <h3 class="font-handwriting text-lg font-bold text-slate-800 truncate">
      <%= list.title %>
    </h3>

    <!-- Actions (visible on hover) -->
    <div class="opacity-0 group-hover:opacity-100 transition-opacity flex gap-1">
      <%= render 'lists/actions', list: list %>
    </div>
  </header>

  <!-- Todos -->
  <ul class="space-y-2" data-controller="sortable" data-sortable-resource-value="todos">
    <%= render list.todos.rank(:row_order) %>
  </ul>

  <!-- Add todo button -->
  <footer class="mt-4 pt-3 border-t border-slate-300/50">
    <%= link_to new_list_todo_path(list),
        class: "flex items-center gap-2 text-sm text-slate-500 hover:text-slate-700",
        data: { turbo_frame: "modal" } do %>
      <%= heroicon "plus", variant: :mini, class: "w-4 h-4" %>
      <span>Add task</span>
    <% end %>
  </footer>
</div>
```

**Commit:** `feat: implement modern design system with color themes`

---

### 4.3 Micro-Interactions & Animations

#### 4.3.1 Add CSS Animations

```css
/* app/assets/stylesheets/application.tailwind.css */
@layer utilities {
  /* Entrance animations */
  .animate-slide-up {
    animation: slideUp 0.3s ease-out;
  }

  .animate-fade-in {
    animation: fadeIn 0.2s ease-out;
  }

  .animate-scale-in {
    animation: scaleIn 0.2s ease-out;
  }

  /* Completion animation */
  .animate-complete {
    animation: complete 0.4s ease-out;
  }
}

@keyframes slideUp {
  from { opacity: 0; transform: translateY(10px); }
  to { opacity: 1; transform: translateY(0); }
}

@keyframes fadeIn {
  from { opacity: 0; }
  to { opacity: 1; }
}

@keyframes scaleIn {
  from { opacity: 0; transform: scale(0.95); }
  to { opacity: 1; transform: scale(1); }
}

@keyframes complete {
  0% { transform: scale(1); }
  50% { transform: scale(1.05); }
  100% { transform: scale(1); }
}

/* Checkbox custom styling */
.checkbox-custom {
  @apply relative w-5 h-5 rounded border-2 border-slate-400
         cursor-pointer transition-all duration-200
         checked:bg-green-500 checked:border-green-500;
}

.checkbox-custom:checked::after {
  content: '';
  @apply absolute inset-0 flex items-center justify-center;
  background-image: url("data:image/svg+xml,%3csvg viewBox='0 0 16 16' fill='white' xmlns='http://www.w3.org/2000/svg'%3e%3cpath d='M12.207 4.793a1 1 0 010 1.414l-5 5a1 1 0 01-1.414 0l-2-2a1 1 0 011.414-1.414L6.5 9.086l4.293-4.293a1 1 0 011.414 0z'/%3e%3c/svg%3e");
}
```

#### 4.3.2 Enhanced Stimulus Controllers

```javascript
// app/javascript/controllers/todo_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["checkbox", "content"]
  static classes = ["completed"]

  toggle(event) {
    const isCompleted = event.target.checked

    // Optimistic UI update
    this.contentTarget.classList.toggle(this.completedClass, isCompleted)

    // Add celebration animation
    if (isCompleted) {
      this.element.classList.add("animate-complete")
      this.#confetti()
    }

    // Submit form via Turbo
    event.target.form.requestSubmit()
  }

  #confetti() {
    // Mini confetti burst for task completion
    const colors = ['#10B981', '#3B82F6', '#F59E0B', '#EF4444']
    // Implementation with canvas or CSS particles
  }
}
```

**Commit:** `feat: add micro-interactions and animations`

---

### 4.4 Accessibility (WCAG 2.1 AA)

#### 4.4.1 Semantic HTML & ARIA

```erb
<%# app/views/dashboard/index.html.erb %>
<main role="main" aria-label="Task board">
  <h1 class="sr-only">Your Task Board</h1>

  <section aria-label="Task lists" class="grid gap-4">
    <%= render @lists %>
  </section>

  <!-- Screen reader announcements -->
  <div
    aria-live="polite"
    aria-atomic="true"
    class="sr-only"
    data-controller="announcer"
    data-announcer-target="region"
  ></div>
</main>
```

#### 4.4.2 Keyboard Navigation

```javascript
// app/javascript/controllers/keyboard_navigation_controller.js
import { Controller } from "@hotwired/stimulus"

export default class extends Controller {
  static targets = ["item"]

  connect() {
    this.currentIndex = 0
    document.addEventListener("keydown", this.handleKeydown.bind(this))
  }

  disconnect() {
    document.removeEventListener("keydown", this.handleKeydown.bind(this))
  }

  handleKeydown(event) {
    const handlers = {
      "ArrowDown": () => this.#moveFocus(1),
      "ArrowUp": () => this.#moveFocus(-1),
      "ArrowRight": () => this.#moveToNextList(),
      "ArrowLeft": () => this.#moveToPrevList(),
      "Enter": () => this.#activateItem(),
      "Space": () => this.#toggleItem(),
      "n": () => event.ctrlKey && this.#createNew(),
      "?": () => this.#showHelp(),
    }

    const handler = handlers[event.key]
    if (handler) {
      event.preventDefault()
      handler()
    }
  }

  #moveFocus(delta) {
    this.currentIndex = Math.max(0,
      Math.min(this.itemTargets.length - 1, this.currentIndex + delta))
    this.itemTargets[this.currentIndex]?.focus()
  }
}
```

#### 4.4.3 Focus Management

```css
/* Focus visible styles */
@layer utilities {
  .focus-ring {
    @apply focus:outline-none focus-visible:ring-2
           focus-visible:ring-brand-500 focus-visible:ring-offset-2;
  }
}
```

#### 4.4.4 Color Contrast & Reduced Motion

```css
/* Respect user preferences */
@media (prefers-reduced-motion: reduce) {
  *, *::before, *::after {
    animation-duration: 0.01ms !important;
    animation-iteration-count: 1 !important;
    transition-duration: 0.01ms !important;
  }
}

@media (prefers-contrast: high) {
  .note-card {
    @apply border-2 border-slate-900;
  }
}
```

**Commit:** `feat: implement WCAG 2.1 AA accessibility standards`

---

### 4.5 Progressive Web App (PWA)

#### 4.5.1 Web App Manifest

```json
// public/manifest.json
{
  "name": "Notky - Digital Corkboard",
  "short_name": "Notky",
  "description": "Organize your tasks with sticky notes",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#1e293b",
  "theme_color": "#0ea5e9",
  "icons": [
    {
      "src": "/icon-192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "/icon-512.png",
      "sizes": "512x512",
      "type": "image/png"
    },
    {
      "src": "/icon-maskable.png",
      "sizes": "512x512",
      "type": "image/png",
      "purpose": "maskable"
    }
  ]
}
```

#### 4.5.2 Service Worker

```javascript
// public/sw.js
const CACHE_NAME = 'notky-v1'
const STATIC_ASSETS = [
  '/',
  '/assets/application.css',
  '/assets/application.js',
  '/icon-192.png',
  '/offline.html'
]

self.addEventListener('install', event => {
  event.waitUntil(
    caches.open(CACHE_NAME).then(cache => cache.addAll(STATIC_ASSETS))
  )
})

self.addEventListener('fetch', event => {
  // Network-first strategy for API calls
  if (event.request.url.includes('/api/') ||
      event.request.method !== 'GET') {
    return
  }

  // Cache-first for static assets
  event.respondWith(
    caches.match(event.request).then(cached => {
      return cached || fetch(event.request).then(response => {
        const clone = response.clone()
        caches.open(CACHE_NAME).then(cache => cache.put(event.request, clone))
        return response
      })
    }).catch(() => caches.match('/offline.html'))
  )
})
```

**Commit:** `feat: add PWA support with offline capabilities`

---

## 5. Phase 4: Feature Enhancements

### 5.1 List Color Customization

**Migration:**

```ruby
# db/migrate/xxx_add_color_to_lists.rb
class AddColorToLists < ActiveRecord::Migration[7.1]
  def change
    add_column :lists, :color, :string, default: 'yellow', null: false
    add_check_constraint :lists,
      "color IN ('yellow', 'pink', 'blue', 'green', 'purple', 'orange')",
      name: 'valid_list_colors'
  end
end
```

**UI Implementation:**

```erb
<%# app/views/lists/_color_picker.html.erb %>
<div class="flex gap-2" data-controller="color-picker">
  <% %w[yellow pink blue green purple orange].each do |color| %>
    <button
      type="button"
      class="w-8 h-8 rounded-full bg-note-<%= color %> border-2
             hover:scale-110 transition-transform
             aria-selected:ring-2 aria-selected:ring-brand-500"
      data-action="click->color-picker#select"
      data-color="<%= color %>"
      aria-label="Select <%= color %> color"
      aria-selected="<%= @list.color == color %>"
    ></button>
  <% end %>
</div>
```

**Commit:** `feat: add list color customization`

---

### 5.2 Due Date Reminders & Notifications

**Model Enhancement:**

```ruby
# app/models/todo.rb
class Todo < ApplicationRecord
  scope :overdue, -> { where(completed: false).where('due_date < ?', Time.current) }
  scope :due_today, -> { where(completed: false).where(due_date: Time.current.all_day) }
  scope :due_soon, -> { where(completed: false).where(due_date: Time.current..3.days.from_now) }

  after_save :schedule_reminder, if: :due_date_changed?

  private

  def schedule_reminder
    return unless due_date.present? && due_date > Time.current

    DueDateReminderJob.set(wait_until: due_date - 1.hour).perform_later(id)
  end
end
```

**Visual Due Date Indicators:**

```erb
<%# app/views/todos/_due_date_badge.html.erb %>
<% if todo.due_date.present? %>
  <span class="<%= due_date_classes(todo) %>">
    <%= heroicon due_date_icon(todo), variant: :mini, class: "w-3 h-3" %>
    <%= todo.due_date.strftime('%b %d') %>
  </span>
<% end %>
```

```ruby
# app/helpers/todos_helper.rb
module TodosHelper
  def due_date_classes(todo)
    base = "inline-flex items-center gap-1 text-xs px-2 py-0.5 rounded-full"

    if todo.due_date < Time.current
      "#{base} bg-red-100 text-red-700"
    elsif todo.due_date < 1.day.from_now
      "#{base} bg-orange-100 text-orange-700"
    elsif todo.due_date < 3.days.from_now
      "#{base} bg-yellow-100 text-yellow-700"
    else
      "#{base} bg-slate-100 text-slate-600"
    end
  end

  def due_date_icon(todo)
    todo.due_date < Time.current ? "exclamation-circle" : "calendar"
  end
end
```

**Commit:** `feat: add due date reminders and visual indicators`

---

### 5.3 Search & Filter

**Controller:**

```ruby
# app/controllers/search_controller.rb
class SearchController < ApplicationController
  def index
    @query = params[:q]
    @results = search_service.call

    respond_to do |format|
      format.turbo_stream
      format.html
    end
  end

  private

  def search_service
    SearchService.new(
      user: current_user,
      query: @query,
      filters: filter_params
    )
  end

  def filter_params
    params.permit(:completed, :due, :list_id)
  end
end
```

**Search UI:**

```erb
<%# app/views/layouts/_search.html.erb %>
<div class="relative" data-controller="search">
  <input
    type="search"
    placeholder="Search tasks... (⌘K)"
    class="w-full pl-10 pr-4 py-2 rounded-lg border border-slate-300
           focus:border-brand-500 focus:ring-1 focus:ring-brand-500"
    data-action="input->search#query keydown.meta+k@window->search#focus"
    data-search-target="input"
  >
  <%= heroicon "magnifying-glass", class: "absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-slate-400" %>

  <!-- Results dropdown -->
  <div
    class="absolute top-full left-0 right-0 mt-2 bg-white rounded-lg shadow-xl border
           hidden data-[open]:block max-h-96 overflow-y-auto"
    data-search-target="results"
  >
    <!-- Results rendered via Turbo Stream -->
  </div>
</div>
```

**Commit:** `feat: add search and filter functionality`

---

### 5.4 Keyboard Shortcuts Modal

```erb
<%# app/views/shared/_keyboard_shortcuts.html.erb %>
<dialog
  class="rounded-xl shadow-2xl p-0 backdrop:bg-slate-900/50"
  data-controller="shortcuts-modal"
  data-action="keydown.?@window->shortcuts-modal#toggle"
>
  <div class="p-6 min-w-[400px]">
    <header class="flex justify-between items-center mb-4">
      <h2 class="text-lg font-semibold">Keyboard Shortcuts</h2>
      <button data-action="click->shortcuts-modal#close">
        <%= heroicon "x-mark", class: "w-5 h-5" %>
      </button>
    </header>

    <dl class="space-y-2">
      <% shortcuts.each do |shortcut| %>
        <div class="flex justify-between py-1">
          <dt class="text-slate-600"><%= shortcut[:description] %></dt>
          <dd>
            <kbd class="px-2 py-1 bg-slate-100 rounded text-sm font-mono">
              <%= shortcut[:keys] %>
            </kbd>
          </dd>
        </div>
      <% end %>
    </dl>
  </div>
</dialog>
```

**Commit:** `feat: add keyboard shortcuts with help modal`

---

### 5.5 Drag & Drop Enhancements

**Enhanced Sortable Controller:**

```javascript
// app/javascript/controllers/sortable_controller.js
import { Controller } from "@hotwired/stimulus"
import Sortable from "sortablejs"

export default class extends Controller {
  static values = {
    resource: String,
    group: { type: String, default: "" }
  }

  connect() {
    this.sortable = Sortable.create(this.element, {
      animation: 150,
      ghostClass: "sortable-ghost",
      chosenClass: "sortable-chosen",
      dragClass: "sortable-drag",
      handle: "[data-sortable-handle]",
      group: this.groupValue || undefined,

      onStart: this.#onStart.bind(this),
      onEnd: this.#onEnd.bind(this),
      onMove: this.#onMove.bind(this),
    })
  }

  #onStart(event) {
    document.body.classList.add("is-dragging")
    this.element.setAttribute("aria-busy", "true")
  }

  #onEnd(event) {
    document.body.classList.remove("is-dragging")
    this.element.setAttribute("aria-busy", "false")

    const { item, newIndex, from, to } = event
    const id = item.dataset.id

    // Handle cross-list moves for todos
    if (from !== to && this.resourceValue === "todos") {
      this.#moveToList(id, to.dataset.listId, newIndex)
    } else {
      this.#updatePosition(id, newIndex)
    }
  }

  #updatePosition(id, position) {
    const url = `/${this.resourceValue}/${id}/sort`
    fetch(url, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
      },
      body: JSON.stringify({ position })
    })
  }

  #moveToList(todoId, listId, position) {
    const url = `/todos/${todoId}/move`
    fetch(url, {
      method: "PATCH",
      headers: {
        "Content-Type": "application/json",
        "X-CSRF-Token": document.querySelector("[name='csrf-token']").content
      },
      body: JSON.stringify({ list_id: listId, position })
    })
  }
}
```

**CSS for Drag States:**

```css
/* Drag and drop visual feedback */
.sortable-ghost {
  @apply opacity-40 bg-brand-100 border-2 border-dashed border-brand-400;
}

.sortable-chosen {
  @apply shadow-2xl scale-105 rotate-2 z-50;
}

.sortable-drag {
  @apply cursor-grabbing;
}

body.is-dragging * {
  cursor: grabbing !important;
}

/* Drop zone indicator */
[data-sortable-dropzone].is-over {
  @apply ring-2 ring-brand-500 ring-offset-2 bg-brand-50;
}
```

**Commit:** `feat: enhance drag-drop with cross-list moves and visual feedback`

---

## 6. Phase 5: Testing & CI/CD

### 6.1 Test Coverage Goals

| Test Type | Current | Target |
|-----------|---------|--------|
| Unit Tests | ~60% | 90% |
| Integration | ~40% | 80% |
| E2E/System | ~30% | 70% |
| Overall | ~50% | 85% |

### 6.2 Missing Test Cases

**Models:**

```ruby
# spec/models/todo_spec.rb
RSpec.describe Todo, type: :model do
  describe 'validations' do
    it { should validate_presence_of(:title) }
    it { should validate_length_of(:title).is_at_most(255) }
    it { should validate_length_of(:description).is_at_most(1000) }
  end

  describe 'scopes' do
    describe '.overdue' do
      it 'returns incomplete todos past due date'
      it 'excludes completed todos'
      it 'excludes todos without due dates'
    end

    describe '.due_soon' do
      it 'returns todos due within 3 days'
    end
  end

  describe 'callbacks' do
    describe '#schedule_reminder' do
      it 'schedules a reminder job when due_date is set'
      it 'does not schedule for past dates'
    end
  end
end
```

**System Tests:**

```ruby
# spec/features/drag_and_drop_spec.rb
RSpec.describe 'Drag and Drop', type: :feature, js: true do
  describe 'reordering lists' do
    it 'persists list order after page reload'
    it 'announces reorder to screen readers'
  end

  describe 'moving todos between lists' do
    it 'moves a todo to a different list'
    it 'updates the position in the new list'
    it 'removes from the original list'
  end

  describe 'keyboard reordering' do
    it 'reorders with Ctrl+Arrow keys'
  end
end

# spec/features/accessibility_spec.rb
RSpec.describe 'Accessibility', type: :feature, js: true do
  it 'has no accessibility violations on dashboard'
  it 'supports keyboard-only navigation'
  it 'announces dynamic content changes'
  it 'maintains focus after modal close'
  it 'respects prefers-reduced-motion'
end
```

**Commit:** `test: add comprehensive test coverage`

---

### 6.3 Enhanced CI/CD Pipeline

```yaml
# .github/workflows/ci.yml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

env:
  RAILS_ENV: test
  DATABASE_URL: postgres://postgres:postgres@localhost:5432/notky_test

jobs:
  lint:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.3'
          bundler-cache: true

      - name: Run RuboCop
        run: bundle exec rubocop --parallel

      - name: Run ERB Lint
        run: bundle exec erblint --lint-all

      - name: Run Brakeman
        run: bundle exec brakeman -q --no-pager

  test:
    runs-on: ubuntu-latest
    needs: lint

    services:
      postgres:
        image: postgres:16
        env:
          POSTGRES_PASSWORD: postgres
        ports:
          - 5432:5432
        options: >-
          --health-cmd pg_isready
          --health-interval 10s
          --health-timeout 5s
          --health-retries 5

      redis:
        image: redis:7
        ports:
          - 6379:6379

    steps:
      - uses: actions/checkout@v4

      - uses: ruby/setup-ruby@v1
        with:
          ruby-version: '3.3'
          bundler-cache: true

      - name: Setup Node
        uses: actions/setup-node@v4
        with:
          node-version: '20'

      - name: Install Chrome
        uses: browser-actions/setup-chrome@v1

      - name: Setup database
        run: |
          bundle exec rails db:create db:schema:load

      - name: Compile assets
        run: |
          bundle exec rails assets:precompile

      - name: Run tests
        run: |
          bundle exec rspec --format progress --format RspecJunitFormatter --out tmp/rspec.xml

      - name: Upload coverage
        uses: codecov/codecov-action@v4
        with:
          files: ./coverage/.resultset.json

      - name: Upload test results
        uses: actions/upload-artifact@v4
        if: always()
        with:
          name: test-results
          path: tmp/rspec.xml

  build:
    runs-on: ubuntu-latest
    needs: test
    if: github.ref == 'refs/heads/main'

    steps:
      - uses: actions/checkout@v4

      - name: Set up Docker Buildx
        uses: docker/setup-buildx-action@v3

      - name: Login to Container Registry
        uses: docker/login-action@v3
        with:
          registry: ghcr.io
          username: ${{ github.actor }}
          password: ${{ secrets.GITHUB_TOKEN }}

      - name: Build and push
        uses: docker/build-push-action@v5
        with:
          context: .
          push: true
          tags: |
            ghcr.io/${{ github.repository }}:latest
            ghcr.io/${{ github.repository }}:${{ github.sha }}
          cache-from: type=gha
          cache-to: type=gha,mode=max
```

**Commit:** `ci: enhance CI/CD pipeline with parallel jobs and Docker builds`

---

## 7. Phase 6: Security Hardening

### 7.1 Authentication Enhancements

```ruby
# Gemfile additions
gem 'devise-two-factor'
gem 'webauthn'  # Passkey support
gem 'rack-attack'  # Rate limiting
```

**Rate Limiting:**

```ruby
# config/initializers/rack_attack.rb
class Rack::Attack
  # Throttle login attempts
  throttle('logins/ip', limit: 5, period: 60.seconds) do |req|
    req.ip if req.path == '/users/sign_in' && req.post?
  end

  # Throttle API requests
  throttle('api/ip', limit: 100, period: 60.seconds) do |req|
    req.ip if req.path.start_with?('/api/')
  end

  # Block suspicious requests
  blocklist('block bad IPs') do |req|
    Rack::Attack::Fail2Ban.filter("bad-ips:#{req.ip}",
      maxretry: 3, findtime: 10.minutes, bantime: 1.hour) do
      req.path.include?('/wp-admin') ||
      req.path.include?('.php')
    end
  end
end
```

**Commit:** `security: add rate limiting and brute-force protection`

---

### 7.2 Content Security Policy

```ruby
# config/initializers/content_security_policy.rb
Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self
    policy.font_src    :self, 'https://fonts.gstatic.com'
    policy.img_src     :self, :data, :blob
    policy.object_src  :none
    policy.script_src  :self, :strict_dynamic
    policy.style_src   :self, 'https://fonts.googleapis.com', :unsafe_inline
    policy.connect_src :self, 'wss:'  # For Action Cable
    policy.frame_ancestors :none
    policy.base_uri    :self
    policy.form_action :self

    # Report violations
    policy.report_uri '/csp-violation-report'
  end

  config.content_security_policy_nonce_generator = ->(request) {
    SecureRandom.base64(16)
  }
  config.content_security_policy_nonce_directives = %w[script-src]
end
```

**Commit:** `security: strengthen Content Security Policy`

---

### 7.3 Input Validation & Sanitization

```ruby
# app/models/concerns/sanitizable.rb
module Sanitizable
  extend ActiveSupport::Concern

  included do
    before_validation :sanitize_inputs
  end

  private

  def sanitize_inputs
    self.class.attribute_names.each do |attr|
      value = send(attr)
      next unless value.is_a?(String)

      sanitized = ActionController::Base.helpers.sanitize(
        value.strip,
        tags: [],  # No HTML allowed
        attributes: []
      )
      send("#{attr}=", sanitized)
    end
  end
end

# app/models/todo.rb
class Todo < ApplicationRecord
  include Sanitizable

  validates :title, presence: true,
                    length: { maximum: 255 },
                    format: { without: /<script/i, message: 'contains invalid content' }
end
```

**Commit:** `security: add input validation and sanitization`

---

## 8. Phase 7: Deployment & DevOps

### 8.1 Docker Optimization

```dockerfile
# Dockerfile (optimized)
# syntax=docker/dockerfile:1

ARG RUBY_VERSION=3.3
FROM ruby:${RUBY_VERSION}-slim AS base

WORKDIR /rails

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test"

# Build stage
FROM base AS build

# Install build dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    build-essential \
    git \
    libpq-dev \
    node-gyp \
    pkg-config \
    python-is-python3 && \
    rm -rf /var/lib/apt/lists/*

# Install gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

# Copy application code
COPY . .

# Precompile bootsnap
RUN bundle exec bootsnap precompile app/ lib/

# Precompile assets
RUN SECRET_KEY_BASE_DUMMY=1 ./bin/rails assets:precompile

# Final stage
FROM base

# Install runtime dependencies
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
    curl \
    libpq-dev && \
    rm -rf /var/lib/apt/lists/* /var/cache/apt/archives/*

# Copy built artifacts
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /rails /rails

# Run as non-root user
RUN useradd rails --create-home --shell /bin/bash && \
    chown -R rails:rails db log storage tmp
USER rails:rails

# Health check
HEALTHCHECK --interval=30s --timeout=3s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/up || exit 1

EXPOSE 3000

CMD ["./bin/rails", "server", "-b", "0.0.0.0"]
```

**Commit:** `devops: optimize Docker build for smaller images`

---

### 8.2 Docker Compose for Development

```yaml
# docker-compose.yml
version: '3.8'

services:
  web:
    build:
      context: .
      dockerfile: Dockerfile.dev
    ports:
      - "3000:3000"
    volumes:
      - .:/rails
      - bundle_cache:/usr/local/bundle
    environment:
      - DATABASE_URL=postgres://postgres:postgres@db:5432/notky_development
      - REDIS_URL=redis://redis:6379/0
    depends_on:
      - db
      - redis
    stdin_open: true
    tty: true

  db:
    image: postgres:16-alpine
    volumes:
      - postgres_data:/var/lib/postgresql/data
    environment:
      POSTGRES_PASSWORD: postgres
    ports:
      - "5432:5432"

  redis:
    image: redis:7-alpine
    volumes:
      - redis_data:/data
    ports:
      - "6379:6379"

  mailcatcher:
    image: dockage/mailcatcher
    ports:
      - "1080:1080"
      - "1025:1025"

volumes:
  bundle_cache:
  postgres_data:
  redis_data:
```

**Commit:** `devops: add Docker Compose for local development`

---

### 8.3 Production Checklist

**Pre-deployment:**

- [ ] Run full test suite: `bundle exec rspec`
- [ ] Run security scan: `bundle exec brakeman`
- [ ] Check for vulnerabilities: `bundle audit check`
- [ ] Verify assets compile: `rails assets:precompile`
- [ ] Test Docker build: `docker build -t notky .`
- [ ] Run production smoke test locally

**Environment Variables:**

```bash
# Required production environment variables
RAILS_ENV=production
SECRET_KEY_BASE=<generated-secret>
DATABASE_URL=postgres://user:pass@host:5432/notky_production
REDIS_URL=redis://host:6379/0
RAILS_SERVE_STATIC_FILES=true
RAILS_LOG_TO_STDOUT=true
```

**Monitoring Setup:**

```ruby
# Gemfile
gem 'sentry-ruby'
gem 'sentry-rails'

# config/initializers/sentry.rb
Sentry.init do |config|
  config.dsn = ENV['SENTRY_DSN']
  config.breadcrumbs_logger = [:active_support_logger, :http_logger]
  config.traces_sample_rate = 0.2
end
```

**Commit:** `devops: add production monitoring and deployment checklist`

---

## 9. Appendix: Commit Strategy

### Commit Guidelines

Follow conventional commits for clear history:

```
<type>(<scope>): <description>

[optional body]

[optional footer]
```

**Types:**
- `feat`: New feature
- `fix`: Bug fix
- `refactor`: Code refactoring
- `perf`: Performance improvement
- `test`: Adding tests
- `docs`: Documentation
- `chore`: Maintenance tasks
- `ci`: CI/CD changes
- `security`: Security improvements
- `devops`: Infrastructure changes

### Recommended Commit Sequence

```bash
# Phase 1: Foundation
git commit -m "chore: update dependencies to latest stable versions"
git commit -m "refactor: extract service objects for business logic"
git commit -m "refactor: introduce ViewComponent for UI components"
git commit -m "chore: configure enhanced linting rules"

# Phase 2: Database & Performance
git commit -m "feat: migrate from SQLite to PostgreSQL"
git commit -m "perf: add database indexes for common queries"
git commit -m "perf: implement Redis caching with Russian Doll strategy"
git commit -m "feat: add Solid Queue for background job processing"

# Phase 3: UI/UX
git commit -m "feat: implement mobile-first responsive design"
git commit -m "feat: implement modern design system with color themes"
git commit -m "feat: add micro-interactions and animations"
git commit -m "feat: implement WCAG 2.1 AA accessibility standards"
git commit -m "feat: add PWA support with offline capabilities"

# Phase 4: Features
git commit -m "feat: add list color customization"
git commit -m "feat: add due date reminders and visual indicators"
git commit -m "feat: add search and filter functionality"
git commit -m "feat: add keyboard shortcuts with help modal"
git commit -m "feat: enhance drag-drop with cross-list moves"

# Phase 5: Testing
git commit -m "test: add comprehensive test coverage"
git commit -m "ci: enhance CI/CD pipeline with parallel jobs"

# Phase 6: Security
git commit -m "security: add rate limiting and brute-force protection"
git commit -m "security: strengthen Content Security Policy"
git commit -m "security: add input validation and sanitization"

# Phase 7: DevOps
git commit -m "devops: optimize Docker build for smaller images"
git commit -m "devops: add Docker Compose for local development"
git commit -m "devops: add production monitoring and deployment checklist"
```

### GitHub CLI Commands

```bash
# Create feature branch
gh repo sync
git checkout -b feature/modernization-phase-1

# Commit and push
git add -A
git commit -m "feat: implement phase 1 modernization"
git push -u origin feature/modernization-phase-1

# Create PR
gh pr create --title "Phase 1: Foundation & Code Quality" \
  --body "Implements dependency updates, service objects, and ViewComponents"

# Merge after review
gh pr merge --squash --delete-branch
```

---

## Implementation Priority Matrix

| Phase | Priority | Effort | Impact | Dependencies |
|-------|----------|--------|--------|--------------|
| Phase 1 | High | Medium | Medium | None |
| Phase 2 | Medium | High | High | Phase 1 |
| Phase 3 | Critical | High | Very High | Phases 1-2 |
| Phase 4 | Medium | Medium | High | Phase 3 |
| Phase 5 | High | Medium | Medium | Phases 1-4 |
| Phase 6 | High | Low | High | Phase 1 |
| Phase 7 | Medium | Low | Medium | All |

**Recommended Order:** Phase 1 → Phase 6 → Phase 3 → Phase 2 → Phase 4 → Phase 5 → Phase 7

---

## Success Metrics

| Metric | Current | Target |
|--------|---------|--------|
| Lighthouse Performance | ~70 | 95+ |
| Lighthouse Accessibility | ~80 | 100 |
| Test Coverage | ~50% | 85%+ |
| Bundle Size (JS) | ~150KB | <100KB |
| First Contentful Paint | ~1.5s | <0.8s |
| Time to Interactive | ~2.5s | <1.5s |

---

*Document Version: 1.0*
*Generated: January 2026*
*Maintainer: Development Team*
