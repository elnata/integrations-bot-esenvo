Rails.application.config.middleware.use OmniAuth::Builder do
    provider :facebook, '966808040827050', 'ef6c25997137955f9e5d6c09689690cd',
    provider_ignores_state: true
  end