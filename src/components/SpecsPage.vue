<template>
  <div class="specs-page">
    <div class="specs-header">
      <button @click="$router.push('/')" class="back-btn">
        <svg xmlns="http://www.w3.org/2000/svg" width="20" height="20" viewBox="0 0 24 24" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round">
          <path d="M19 12H5M12 19l-7-7 7-7"/>
        </svg>
        Back
      </button>
      <h1>Technical Specifications</h1>
    </div>

    <div class="specs-content">
      <section class="spec-section">
        <h2>Application Overview</h2>
        <p>Melkonian Tax Expense Manager is a modern web application designed for efficient expense tracking and document management. Built with enterprise-grade technologies, it provides a secure, scalable solution for managing business expenses and related documentation.</p>
      </section>

      <section class="spec-section">
        <h2>Core Technology Stack</h2>

        <div class="tech-category">
          <h3>Frontend Framework</h3>
          <div class="tech-item">
            <div class="tech-name">Vue 3</div>
            <div class="tech-desc">Progressive JavaScript framework utilizing the Composition API for component logic and reactive state management. Provides optimal performance with its virtual DOM implementation and fine-grained reactivity system.</div>
          </div>
          <div class="tech-item">
            <div class="tech-name">TypeScript</div>
            <div class="tech-desc">Strongly-typed superset of JavaScript ensuring type safety, improved code quality, and enhanced developer experience through intelligent IDE support and compile-time error detection.</div>
          </div>
        </div>

        <div class="tech-category">
          <h3>Build Tooling</h3>
          <div class="tech-item">
            <div class="tech-name">Vite</div>
            <div class="tech-desc">Next-generation build tool leveraging native ES modules for lightning-fast hot module replacement during development and optimized production builds with code splitting and tree-shaking.</div>
          </div>
        </div>

        <div class="tech-category">
          <h3>Backend & Database</h3>
          <div class="tech-item">
            <div class="tech-name">Supabase</div>
            <div class="tech-desc">Open-source Firebase alternative providing PostgreSQL database, authentication, real-time subscriptions, and file storage. Offers Row-Level Security (RLS) for fine-grained access control at the database level.</div>
          </div>
          <div class="tech-item">
            <div class="tech-name">PostgreSQL</div>
            <div class="tech-desc">Advanced relational database system powering Supabase, offering ACID compliance, robust data integrity, and powerful querying capabilities.</div>
          </div>
        </div>

        <div class="tech-category">
          <h3>Routing</h3>
          <div class="tech-item">
            <div class="tech-name">Vue Router 4</div>
            <div class="tech-desc">Official routing library for Vue 3, providing client-side navigation, route guards, and dynamic route matching for single-page application architecture.</div>
          </div>
        </div>
      </section>

      <section class="spec-section">
        <h2>Architecture Principles</h2>

        <div class="principle">
          <h3>Component-Based Architecture</h3>
          <p>Application is structured using modular, reusable Vue components following the Single Responsibility Principle. Each component encapsulates specific functionality, promoting maintainability and testability.</p>
        </div>

        <div class="principle">
          <h3>Composable Logic</h3>
          <p>Business logic is extracted into composables (useSupabase) following the Composition API pattern, enabling code reuse across components and cleaner separation of concerns.</p>
        </div>

        <div class="principle">
          <h3>Type Safety</h3>
          <p>Comprehensive TypeScript interfaces define data structures (ExpenseCategory, ExpenseDocument, CompanyProfile), providing compile-time validation and improved IDE support throughout the application.</p>
        </div>

        <div class="principle">
          <h3>Security-First Design</h3>
          <p>Multi-layered security approach including passcode authentication, Row-Level Security policies at the database level, and secure file storage with controlled access patterns.</p>
        </div>

        <div class="principle">
          <h3>Database Design</h3>
          <p>Normalized relational schema with three core tables (expense_categories, expense_documents, company_profile) using UUID primary keys and foreign key constraints for referential integrity. All tables include created_at and updated_at timestamps for audit trails.</p>
        </div>

        <div class="principle">
          <h3>File Storage Strategy</h3>
          <p>Supabase Storage bucket (expense-documents) handles file uploads with UUID-based filenames preventing collisions. Public URL generation enables efficient file access while maintaining security controls through bucket policies.</p>
        </div>

        <div class="principle">
          <h3>Responsive Design</h3>
          <p>Mobile-first CSS approach with breakpoints at 640px, ensuring optimal user experience across all device sizes. Viewport lock prevents unintended zooming on mobile devices for app-like stability.</p>
        </div>

        <div class="principle">
          <h3>State Management</h3>
          <p>Reactive state using Vue's ref and computed APIs, eliminating need for external state management libraries while maintaining predictable data flow and component reactivity.</p>
        </div>
      </section>

      <section class="spec-section">
        <h2>Database Schema</h2>

        <div class="schema-table">
          <h3>expense_categories</h3>
          <ul>
            <li><code>id</code> - UUID primary key</li>
            <li><code>name</code> - Category name</li>
            <li><code>description</code> - Category description</li>
            <li><code>display_order</code> - Sort order for UI display</li>
            <li><code>created_at</code> - Timestamp</li>
            <li><code>updated_at</code> - Timestamp</li>
          </ul>
        </div>

        <div class="schema-table">
          <h3>expense_documents</h3>
          <ul>
            <li><code>id</code> - UUID primary key</li>
            <li><code>category_id</code> - Foreign key to expense_categories</li>
            <li><code>title</code> - Document title</li>
            <li><code>description</code> - Document description</li>
            <li><code>document_type</code> - Type (PDF, image, link, other)</li>
            <li><code>url</code> - Document URL or file path</li>
            <li><code>amount</code> - Expense amount (nullable)</li>
            <li><code>date</code> - Expense date</li>
            <li><code>created_at</code> - Timestamp</li>
            <li><code>updated_at</code> - Timestamp</li>
          </ul>
        </div>

        <div class="schema-table">
          <h3>company_profile</h3>
          <ul>
            <li><code>id</code> - UUID primary key</li>
            <li><code>filing_number</code> - State filing number</li>
            <li><code>company_name</code> - Legal company name</li>
            <li><code>address</code> - Business address</li>
            <li><code>phone</code> - Contact phone</li>
            <li><code>email</code> - Contact email</li>
            <li><code>website</code> - Company website</li>
            <li><code>formation_date</code> - Date of formation (nullable)</li>
            <li><code>ein</code> - Employer Identification Number</li>
            <li><code>description</code> - Company description</li>
            <li><code>created_at</code> - Timestamp</li>
            <li><code>updated_at</code> - Timestamp</li>
          </ul>
        </div>
      </section>

      <section class="spec-section">
        <h2>Key Features</h2>

        <ul class="feature-list">
          <li>Passcode-based authentication with session persistence</li>
          <li>Category-based expense organization</li>
          <li>Document upload and management (PDF, images)</li>
          <li>Real-time expense totals and statistics</li>
          <li>Company profile management</li>
          <li>Admin panel for category management</li>
          <li>Comprehensive reporting capabilities</li>
          <li>Responsive design optimized for mobile and desktop</li>
          <li>Document attachments with cloud storage</li>
          <li>Audit trails with timestamp tracking</li>
        </ul>
      </section>

      <section class="spec-section">
        <h2>Security Features</h2>

        <ul class="feature-list">
          <li>Daily passcode authentication requirement</li>
          <li>Row-Level Security (RLS) policies on all database tables</li>
          <li>Secure file storage with controlled access</li>
          <li>Environment variable protection for sensitive credentials</li>
          <li>HTTPS-only communication with backend services</li>
          <li>No sensitive data exposure in client-side code</li>
        </ul>
      </section>

      <section class="spec-section">
        <h2>Performance Optimizations</h2>

        <ul class="feature-list">
          <li>Vite's optimized build process with code splitting</li>
          <li>Tree-shaking to eliminate unused code</li>
          <li>Lazy loading of components and routes</li>
          <li>Efficient database queries with proper indexing</li>
          <li>Optimized image loading and caching</li>
          <li>Minimal runtime overhead with Vue 3's reactivity system</li>
          <li>CSS optimization and minification in production</li>
        </ul>
      </section>

      <section class="spec-section">
        <h2>Development Workflow</h2>

        <div class="principle">
          <h3>Version Control</h3>
          <p>Git-based version control with structured commits and migration tracking for database schema changes.</p>
        </div>

        <div class="principle">
          <h3>Database Migrations</h3>
          <p>SQL migration files with detailed documentation ensure reproducible database schema evolution across environments.</p>
        </div>

        <div class="principle">
          <h3>Type Generation</h3>
          <p>Supabase CLI generates TypeScript types directly from database schema, ensuring type safety between frontend and backend.</p>
        </div>

        <div class="principle">
          <h3>Build Process</h3>
          <p>Two-stage build: TypeScript compilation followed by Vite bundling, ensuring type correctness before production deployment.</p>
        </div>
      </section>
    </div>
  </div>
</template>

<script setup lang="ts">
</script>

<style scoped>
.specs-page {
  min-height: 100vh;
  background: #6394c1;
  padding: 2rem;
}

.specs-header {
  max-width: 1200px;
  margin: 0 auto 2rem;
  display: flex;
  align-items: center;
  gap: 1.5rem;
}

.back-btn {
  display: inline-flex;
  align-items: center;
  gap: 0.5rem;
  padding: 0.75rem 1.25rem;
  background: rgba(255, 255, 255, 0.2);
  backdrop-filter: blur(10px);
  color: white;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-radius: 10px;
  font-size: 1rem;
  font-weight: 600;
  font-family: 'Roboto', sans-serif;
  cursor: pointer;
  transition: all 0.2s;
  text-transform: uppercase;
}

.back-btn:hover {
  background: rgba(255, 255, 255, 0.3);
  transform: translateY(-2px);
}

.specs-header h1 {
  margin: 0;
  font-size: 2.5rem;
  color: white;
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.2);
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.specs-content {
  max-width: 1200px;
  margin: 0 auto;
  background: white;
  border-radius: 16px;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.2);
  overflow: hidden;
}

.spec-section {
  padding: 3rem;
  border-bottom: 2px solid #e0e0e0;
}

.spec-section:last-child {
  border-bottom: none;
}

.spec-section > h2 {
  margin: 0 0 2rem 0;
  font-size: 2rem;
  color: #3d6f9e;
  font-weight: 700;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.spec-section > p {
  font-size: 1.125rem;
  line-height: 1.8;
  color: #333;
  margin: 0;
}

.tech-category {
  margin-bottom: 2.5rem;
}

.tech-category:last-child {
  margin-bottom: 0;
}

.tech-category h3 {
  margin: 0 0 1.25rem 0;
  font-size: 1.5rem;
  color: #5691c4;
  font-weight: 600;
  text-transform: uppercase;
  letter-spacing: 0.05em;
}

.tech-item {
  margin-bottom: 1.5rem;
  padding-left: 1.5rem;
  border-left: 3px solid #5691c4;
}

.tech-item:last-child {
  margin-bottom: 0;
}

.tech-name {
  font-size: 1.25rem;
  font-weight: 600;
  color: #333;
  margin-bottom: 0.5rem;
}

.tech-desc {
  font-size: 1rem;
  line-height: 1.7;
  color: #666;
}

.principle {
  margin-bottom: 2rem;
}

.principle:last-child {
  margin-bottom: 0;
}

.principle h3 {
  margin: 0 0 0.75rem 0;
  font-size: 1.375rem;
  color: #3d6f9e;
  font-weight: 600;
}

.principle p {
  margin: 0;
  font-size: 1rem;
  line-height: 1.7;
  color: #555;
}

.schema-table {
  margin-bottom: 2rem;
  background: #f8f9fa;
  border-radius: 8px;
  padding: 1.5rem;
}

.schema-table:last-child {
  margin-bottom: 0;
}

.schema-table h3 {
  margin: 0 0 1rem 0;
  font-size: 1.25rem;
  color: #3d6f9e;
  font-weight: 600;
  font-family: 'Courier New', monospace;
}

.schema-table ul {
  margin: 0;
  padding-left: 1.5rem;
  list-style: none;
}

.schema-table li {
  margin-bottom: 0.5rem;
  font-size: 0.95rem;
  line-height: 1.6;
  color: #444;
}

.schema-table li:last-child {
  margin-bottom: 0;
}

.schema-table code {
  background: #e3f2fd;
  padding: 0.2rem 0.5rem;
  border-radius: 4px;
  font-family: 'Courier New', monospace;
  font-size: 0.9rem;
  color: #1976d2;
  font-weight: 600;
}

.feature-list {
  margin: 0;
  padding-left: 2rem;
}

.feature-list li {
  margin-bottom: 1rem;
  font-size: 1.0625rem;
  line-height: 1.7;
  color: #444;
}

.feature-list li:last-child {
  margin-bottom: 0;
}

@media (max-width: 768px) {
  .specs-page {
    padding: 1rem;
  }

  .specs-header {
    flex-direction: column;
    align-items: flex-start;
    gap: 1rem;
  }

  .specs-header h1 {
    font-size: 1.75rem;
  }

  .spec-section {
    padding: 2rem 1.5rem;
  }

  .spec-section > h2 {
    font-size: 1.5rem;
    margin-bottom: 1.5rem;
  }

  .tech-category h3 {
    font-size: 1.25rem;
  }

  .tech-item {
    padding-left: 1rem;
  }

  .tech-name {
    font-size: 1.125rem;
  }

  .tech-desc {
    font-size: 0.9375rem;
  }

  .principle h3 {
    font-size: 1.1875rem;
  }

  .principle p {
    font-size: 0.9375rem;
  }

  .schema-table {
    padding: 1rem;
  }
}
</style>
