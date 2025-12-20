/*
  # Create Company Profile Table

  1. New Tables
    - `company_profile`
      - `id` (uuid, primary key)
      - `filing_number` (text) - State filing number
      - `company_name` (text) - Legal company name
      - `address` (text) - Physical address
      - `phone` (text, optional) - Contact phone
      - `email` (text, optional) - Contact email
      - `website` (text, optional) - Company website
      - `formation_date` (date, optional) - Date of formation
      - `ein` (text, optional) - Federal EIN
      - `description` (text, optional) - Company description
      - `created_at` (timestamp)
      - `updated_at` (timestamp)

  2. Security
    - Enable RLS on `company_profile` table
    - Add policy for authenticated users to read company profile
    - Add policy for authenticated users to update company profile
*/

CREATE TABLE IF NOT EXISTS company_profile (
  id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
  filing_number text DEFAULT '',
  company_name text DEFAULT '',
  address text DEFAULT '',
  phone text DEFAULT '',
  email text DEFAULT '',
  website text DEFAULT '',
  formation_date date,
  ein text DEFAULT '',
  description text DEFAULT '',
  created_at timestamptz DEFAULT now(),
  updated_at timestamptz DEFAULT now()
);

ALTER TABLE company_profile ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can read company profile"
  ON company_profile
  FOR SELECT
  USING (true);

CREATE POLICY "Authenticated users can update company profile"
  ON company_profile
  FOR UPDATE
  TO authenticated
  USING (true)
  WITH CHECK (true);

CREATE POLICY "Authenticated users can insert company profile"
  ON company_profile
  FOR INSERT
  TO authenticated
  WITH CHECK (true);

INSERT INTO company_profile (
  filing_number,
  company_name,
  address
) VALUES (
  '224862720630',
  'Melkonian Industries LLC',
  '2680 Diane Marie Ct, Waterford, MI 48329'
) ON CONFLICT DO NOTHING;