/*
  # Create Storage Bucket for Document Uploads
  
  ## Overview
  Sets up Supabase Storage bucket for uploading expense documents with public access.
  
  ## New Storage Bucket
  - `expense-documents` - Bucket for storing PDF files, images, and other document types
  
  ## Security
  - Public read access for all files
  - Public upload/insert access (no auth required per requirements)
  - Public update/delete access for managing files
  
  ## Notes
  - Files will be organized with unique names to prevent conflicts
  - Supports multiple file types: PDF, images (jpg, png), and other document formats
*/

-- Create storage bucket for expense documents
INSERT INTO storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
VALUES (
  'expense-documents',
  'expense-documents',
  true,
  10485760,
  ARRAY['application/pdf', 'image/jpeg', 'image/jpg', 'image/png', 'image/gif', 'image/webp']
)
ON CONFLICT (id) DO NOTHING;

-- Drop existing policies if they exist
DROP POLICY IF EXISTS "Public read access for expense documents" ON storage.objects;
DROP POLICY IF EXISTS "Public insert access for expense documents" ON storage.objects;
DROP POLICY IF EXISTS "Public update access for expense documents" ON storage.objects;
DROP POLICY IF EXISTS "Public delete access for expense documents" ON storage.objects;

-- Create policy for public read access
CREATE POLICY "Public read access for expense documents"
  ON storage.objects FOR SELECT
  TO anon, authenticated
  USING (bucket_id = 'expense-documents');

-- Create policy for public insert access
CREATE POLICY "Public insert access for expense documents"
  ON storage.objects FOR INSERT
  TO anon, authenticated
  WITH CHECK (bucket_id = 'expense-documents');

-- Create policy for public update access
CREATE POLICY "Public update access for expense documents"
  ON storage.objects FOR UPDATE
  TO anon, authenticated
  USING (bucket_id = 'expense-documents')
  WITH CHECK (bucket_id = 'expense-documents');

-- Create policy for public delete access
CREATE POLICY "Public delete access for expense documents"
  ON storage.objects FOR DELETE
  TO anon, authenticated
  USING (bucket_id = 'expense-documents');