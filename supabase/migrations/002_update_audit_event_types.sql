-- =============================================================================
-- Migration: 002_update_audit_event_types.sql
-- Description: Update tax_audit_log event_type CHECK constraint to include
--              auto-fill and document management event types
-- =============================================================================

-- Drop the existing CHECK constraint
ALTER TABLE tax_audit_log 
DROP CONSTRAINT IF EXISTS tax_audit_log_event_type_check;

-- Add new CHECK constraint with expanded event types
ALTER TABLE tax_audit_log 
ADD CONSTRAINT tax_audit_log_event_type_check CHECK (
  event_type IN (
    -- Original event types
    'authentication', 
    'data_access', 
    'data_modification', 
    'calculation', 
    'submission', 
    'signature', 
    'export', 
    'error',
    -- Auto-fill event types
    'auto_fill_started',
    'auto_fill_completed',
    'auto_fill_error',
    -- Document management event types
    'document_uploaded',
    'document_replaced',
    'document_deleted',
    'document_processed',
    -- Interview event types
    'interview_started',
    'interview_completed',
    -- Review/edit event types
    'return_reviewed',
    'return_edited',
    'return_finalized'
  )
);

-- Add comment for documentation
COMMENT ON COLUMN tax_audit_log.event_type IS 'Event type classification. Includes: authentication, data_access, data_modification, calculation, submission, signature, export, error, auto_fill_started, auto_fill_completed, auto_fill_error, document_uploaded, document_replaced, document_deleted, document_processed, interview_started, interview_completed, return_reviewed, return_edited, return_finalized';
