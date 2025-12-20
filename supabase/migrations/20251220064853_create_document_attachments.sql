/*
  # Create Document Attachments Table

  ## Overview
  Allows multiple files and/or URLs to be attached to a single expense document record.
  Each expense document can now have multiple associated files, receipts, or links.

  ## 1. New Tables
    - `document_attachments`
      - `id` (uuid, primary key) - Unique identifier for the attachment
      - `document_id` (uuid, foreign key) - References expense_documents.id
      - `url` (text) - URL or path to the file/document
      - `file_name` (text) - Original file name
      - `file_type` (text) - MIME type or file extension
      - `file_size` (integer, optional) - Size of file in bytes
      - `display_order` (integer) - Order in which attachments should be displayed
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

  ## 2. Security
    - Enable RLS on `document_attachments` table
    - Add policy for public read access to attachments
    - Add policy for authenticated users to insert attachments
    - Add policy for authenticated users to update attachments
    - Add policy for authenticated users to delete attachments

  ## 3. Notes
    - The existing `url` field in expense_documents is kept for backward compatibility
    - New documents should use the attachments table for storing multiple files
    - Foreign key cascade on delete ensures attachments are removed when document is deleted
*/

CREATE TABLE IF NOT EXISTS document_attachments (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  document_id uuid NOT NULL REFERENCES expense_documents(id) ON DELETE CASCADE,
  url text NOT NULL,
  file_name text NOT NULL,
  file_type text DEFAULT '',
  file_size integer,
  display_order integer DEFAULT 0,
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE document_attachments ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read document attachments"
  ON document_attachments
  FOR SELECT
  USING (true);

CREATE POLICY "Authenticated users can insert document attachments"
  ON document_attachments
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

CREATE POLICY "Authenticated users can update document attachments"
  ON document_attachments
  FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Authenticated users can delete document attachments"
  ON document_attachments
  FOR DELETE
  TO authenticated
  USING (true);

-- Create index for faster queries by document_id
CREATE INDEX IF NOT EXISTS idx_document_attachments_document_id 
  ON document_attachments(document_id);

-- Create index for display order
CREATE INDEX IF NOT EXISTS idx_document_attachments_display_order 
  ON document_attachments(document_id, display_order);