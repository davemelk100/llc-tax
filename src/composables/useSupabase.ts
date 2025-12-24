import { createClient } from '@supabase/supabase-js';

const supabaseUrl = import.meta.env.VITE_SUPABASE_URL;
const supabaseKey = import.meta.env.VITE_SUPABASE_ANON_KEY;

const supabase = createClient(supabaseUrl, supabaseKey);

export interface ExpenseCategory {
  id: string;
  name: string;
  description: string;
  display_order: number;
  created_at: string;
  updated_at: string;
}

export interface ExpenseDocument {
  id: string;
  category_id: string;
  title: string;
  description: string;
  document_type: string;
  url: string;
  amount: number | null;
  date: string;
  created_at: string;
  updated_at: string;
}

export interface CompanyProfile {
  id: string;
  filing_number: string;
  company_name: string;
  address: string;
  phone: string;
  email: string;
  website: string;
  formation_date: string | null;
  ein: string;
  description: string;
  created_at: string;
  updated_at: string;
}

export const useSupabase = () => {
  const signUp = async (email: string, password: string) => {
    const { data, error } = await supabase.auth.signUp({
      email,
      password,
    });
    if (error) throw new Error(error.message);
    return data;
  };

  const signIn = async (email: string, password: string) => {
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password,
    });
    if (error) throw new Error(error.message);
    return data;
  };

  const signOut = async () => {
    const { error } = await supabase.auth.signOut();
    if (error) throw new Error(error.message);
  };

  const getSession = async () => {
    const { data: { session }, error } = await supabase.auth.getSession();
    if (error) throw new Error(error.message);
    return session;
  };

  const onAuthStateChange = (callback: (event: string, session: any) => void) => {
    return supabase.auth.onAuthStateChange((event, session) => {
      (async () => {
        callback(event, session);
      })();
    });
  };

  const getCategories = async (): Promise<ExpenseCategory[]> => {
    const { data, error } = await supabase
      .from('expense_categories')
      .select('*')
      .order('display_order', { ascending: true });

    if (error) throw new Error(error.message);
    return data || [];
  };

  const getDocuments = async (categoryId?: string): Promise<ExpenseDocument[]> => {
    let query = supabase
      .from('expense_documents')
      .select('*')
      .order('date', { ascending: false });

    if (categoryId) {
      query = query.eq('category_id', categoryId);
    }

    const { data, error } = await query;

    if (error) throw new Error(error.message);
    return data || [];
  };

  const createCategory = async (input: {
    name: string;
    description?: string;
    display_order?: number;
  }): Promise<ExpenseCategory> => {
    const { data, error } = await supabase
      .from('expense_categories')
      .insert({
        name: input.name,
        description: input.description || '',
        display_order: input.display_order || 0,
      })
      .select()
      .single();

    if (error) throw new Error(error.message);
    return data;
  };

  const updateCategory = async (
    id: string,
    input: {
      name?: string;
      description?: string;
      display_order?: number;
    }
  ): Promise<ExpenseCategory> => {
    const { data, error } = await supabase
      .from('expense_categories')
      .update({
        ...input,
        updated_at: new Date().toISOString(),
      })
      .eq('id', id)
      .select()
      .single();

    if (error) throw new Error(error.message);
    return data;
  };

  const deleteCategory = async (id: string): Promise<boolean> => {
    const { error } = await supabase
      .from('expense_categories')
      .delete()
      .eq('id', id);

    if (error) throw new Error(error.message);
    return true;
  };

  const createDocument = async (input: {
    category_id: string;
    title: string;
    description?: string;
    document_type?: string;
    url: string;
    amount?: number;
    date?: string;
  }): Promise<ExpenseDocument> => {
    const { data, error } = await supabase
      .from('expense_documents')
      .insert({
        category_id: input.category_id,
        title: input.title,
        description: input.description || '',
        document_type: input.document_type || 'link',
        url: input.url,
        amount: input.amount || null,
        date: input.date || new Date().toISOString().split('T')[0],
      })
      .select()
      .single();

    if (error) throw new Error(error.message);
    return data;
  };

  const updateDocument = async (
    id: string,
    input: {
      title?: string;
      description?: string;
      document_type?: string;
      url?: string;
      amount?: number;
      date?: string;
    }
  ): Promise<ExpenseDocument> => {
    const { data, error } = await supabase
      .from('expense_documents')
      .update({
        ...input,
        updated_at: new Date().toISOString(),
      })
      .eq('id', id)
      .select()
      .single();

    if (error) throw new Error(error.message);
    return data;
  };

  const deleteDocument = async (id: string): Promise<boolean> => {
    const { error } = await supabase
      .from('expense_documents')
      .delete()
      .eq('id', id);

    if (error) throw new Error(error.message);
    return true;
  };

  const uploadFile = async (file: File): Promise<string> => {
    const fileExt = file.name.split('.').pop();
    const fileName = `${crypto.randomUUID()}.${fileExt}`;
    const filePath = `${fileName}`;

    const { error: uploadError } = await supabase.storage
      .from('expense-documents')
      .upload(filePath, file, {
        cacheControl: '60',
        upsert: false
      });

    if (uploadError) throw new Error(uploadError.message);

    const { data } = supabase.storage
      .from('expense-documents')
      .getPublicUrl(filePath);

    return data.publicUrl;
  };

  const getCompanyProfile = async (): Promise<CompanyProfile | null> => {
    const { data, error } = await supabase
      .from('company_profile')
      .select('*')
      .maybeSingle();

    if (error) throw new Error(error.message);
    return data;
  };

  const updateCompanyProfile = async (
    id: string,
    input: Partial<Omit<CompanyProfile, 'id' | 'created_at' | 'updated_at'>>
  ): Promise<CompanyProfile> => {
    const { data, error } = await supabase
      .from('company_profile')
      .update({
        ...input,
        updated_at: new Date().toISOString(),
      })
      .eq('id', id)
      .select()
      .single();

    if (error) throw new Error(error.message);
    return data;
  };

  return {
    signUp,
    signIn,
    signOut,
    getSession,
    onAuthStateChange,
    getCategories,
    getDocuments,
    createCategory,
    updateCategory,
    deleteCategory,
    createDocument,
    updateDocument,
    deleteDocument,
    uploadFile,
    getCompanyProfile,
    updateCompanyProfile,
  };
};
