/*
  # Fix Document Attachments RLS Policies

  ## Overview
  Updates RLS policies for document_attachments table to allow anonymous users,
  matching the access patterns used by other tables and storage buckets in the application.

  ## Changes
    - Drop existing restrictive policies that only allow authenticated users
    - Create new policies that allow both anonymous and authenticated users
    - This matches the pattern used in storage buckets and other tables

  ## Security Notes
    - The application uses client-side passcode authentication, not Supabase auth
    - Policies need to allow 'anon' role in addition to 'authenticated' role
    - Public access is intentional per application requirements
*/

-- Drop existing policies
DROP POLICY IF EXISTS "Anyone can read document attachments" ON document_attachments;
DROP POLICY IF EXISTS "Authenticated users can insert document attachments" ON document_attachments;
DROP POLICY IF EXISTS "Authenticated users can update document attachments" ON document_attachments;
DROP POLICY IF EXISTS "Authenticated users can delete document attachments" ON document_attachments;

-- Create new policies that allow both anon and authenticated users
CREATE POLICY "Public read access for document attachments"
  ON document_attachments
  FOR SELECT
  TO anon, authenticated
  USING (true);

CREATE POLICY "Public insert access for document attachments"
  ON document_attachments
  FOR INSERT
  TO anon, authenticated
  WITH CHECK (true);

CREATE POLICY "Public update access for document attachments"
  ON document_attachments
  FOR UPDATE
  TO anon, authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Public delete access for document attachments"
  ON document_attachments
  FOR DELETE
  TO anon, authenticated
  USING (true);