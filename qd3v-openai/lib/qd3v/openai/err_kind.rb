module Qd3v
  module OpenAI
    module ErrKind
      RESPONSE_ERROR       = EK[:response_error]
      RESPONSE_PARSE_ERROR = EK[:response_parse_error]

      ASSISTANT_NOT_FOUND    = EK[:assistant_not_found]
      ASSISTANT_CREATE_ERROR = EK[:assistant_create_error]
      ASSISTANT_UPDATE_ERROR = EK[:assistant_update_error]

      THREAD_NOT_FOUND              = EK[:thread_not_found]
      THREAD_CREATION_ERROR         = EK[:thread_creation_error]
      THREAD_DELETION_ERROR         = EK[:thread_deletion_error]
      THREAD_MESSAGE_CREATION_ERROR = EK[:thread_message_creation_error]
      THREAD_RUN_CREATION_ERROR     = EK[:thread_run_creation_error]

      EMBEDDING_CREATION_ERROR = EK[:embedding_creation_error]
    end
  end
end
