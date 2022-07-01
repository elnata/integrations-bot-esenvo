class FacebookUser  
    attr_reader :email, :provider, :name, :facebook_uuid, :id_token
  def initialize(email:, name:, provider: 'facebook', id_token: nil, facebook_uuid:)    
      @email = email&.downcase    
      @provider = provider&.to_s    
      @id_token = id_token    
      @name = name    
      @facebook_uuid = facebook_uuid  
    end
  def self.begin_session!(session, omniauth_payload)
      session['facebook_user'] = {
        'email' => omniauth_payload.info.email,
        'name' => omniauth_payload.info.name,
        'facebook_uuid' => omniauth_payload.uid,
        'last_active_at' => Time.zone.now,
        'id_token' => omniauth_payload.credentials.token,
        'provider' => omniauth_payload.provider
      }
    end
  def self.load_from_session(session)
      facebook_sign_in_session = session['facebook_user']
      return unless facebook_sign_in_session
  new(      
        email: facebook_sign_in_session['email'],      
        id_token: facebook_sign_in_session['id_token'],      
        name: facebook_sign_in_session['name'],      
        facebook_uuid: facebook_sign_in_session['facebook_uuid'],          
        provider: facebook_sign_in_session['provider']
      )  
    end
  private
    def signed_in_from_facebook?    
       @provider == 'facebook'  
    end
  end