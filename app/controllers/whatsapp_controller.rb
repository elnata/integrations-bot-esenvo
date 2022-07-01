class WhatsappController < ApplicationController
  skip_before_action :verify_authenticity_token
  before_action :Whats_params, only: [:index, :webhook]

  require 'json'
  require 'httparty'

  def index

  name = params[:message]['visitor']['name']
  phone = params[:message]['from']
  subscriptionId = params[:subscriptionId]
  message = params[:message]['contents'][0]['text']

  if params[:message]['contents'][0]['fileUrl'].present?
    message = params[:message]['contents'][0]['fileUrl']
  end

  # salva o cliente, caso não exista

  client = create_client(name, phone, subscriptionId) 


  #exibindo no console o que foi recebido 
  puts "-----------"
  puts "mensagem do cliente: #{message} - Número : #{phone}"
  puts "-----------"

  # salva a mensagem do usuário
  create_message(client.id, message, 'client') 

  # Envia a mensagem para o bot

  client = Client.find_by(subscriptionId: subscriptionId)

  # puts client.human == true

  # if (client.human == true)
  #   result = human_true(phone, message, name, subscriptionId, client)
  # else    
    result = human_false(subscriptionId, message, client, name, phone)
  # end

  

   
  render json: {
    messages: "ok",
    is_success: true,
    data: {}
  }, status: :ok 

  end

  def webhook

    message = params[:message]
    subscriptionId = params[:subscriptionId]
   

    client = Client.find_by(subscriptionId: subscriptionId)
    
    if (message == '#sair#')

      puts '*/*/*/*/'
     puts client.id
      
      update = client.update(human: false)
      
      post_whats('Atendimento encerrado', client.phone)
    else
      post_whats(message, client.phone)
    end

    
  end

  private

  def human_true(phone, message, name, subscriptionId, client)
      puts "-----------"
      puts "mensagem do cliente: #{message} - Para o número o atendente"
      puts "-----------"     

      # salva a mensagem do usuário
      create_message(client.id, message, 'client')

      chat_human(message,name,phone,subscriptionId)

  end

  def chat_human(message,name,phone,subscriptionId)

    url = "http://localhost:3006/api/v1/index"
   
    email = "#{subscriptionId}@nabot.com"

    user = name.parameterize

     

    body = {       
      text: message,
      nome: user,
      email: email,
      username: user,
      password: '123456',
      company: 'nabot',
      subscriptionId: subscriptionId

    }
    
    result = HTTParty.post(url, 
      :body => body.to_json,
      :headers => { 'Content-Type' => 'application/json' } )
    
  end



  def create_client(name, phone, subscriptionId)

    Client.find_or_create_by(
      name: name,
      phone: phone,
      subscriptionId: subscriptionId
  
    )
    
    
  end

def create_message(client_id, message, type)

  message = Message.new
  message.client_id = client_id
  message.message = message
  message.type = type
  message.save
  
end

def update_client(client_id, phone, message, name, subscriptionId, client)

  client = Client.find_by(id: client_id)
  client.update(human: true)

  atendende = '#atendente#'

  result = human_true(phone, atendende, name, subscriptionId, client)
  
end

def post_bot(subscriptionId, message)

  url = "https://5dbc-177-37-173-214.ngrok.io/api/v1/bots/pablomarcal/converse/#{subscriptionId}"
  # url = "https://5dbc-177-37-173-214.ngrok.io/api/v1/bots/pablomarcal/converse/34te4dasdadawdsdadwadrgdadatru86dad78i78u"
   

    body = { 
      type: "text",
      text: message     
    }
    
    result = HTTParty.post(url, 
      :body => body.to_json,
      :headers => { 'Content-Type' => 'application/json' } )
  
end

def post_whats(message, phone, type, link, botao, qtd_btn)
  require 'json'


   puts botao
   puts qtd_btn
  url = "https://api.zenvia.com/v2/channels/whatsapp/messages"

   
    if type == 'text'
      body = { 
        from: "wild-newsprint",
        to: phone,
        contents: [{"type":"text","text":"#{message}"}]
      }
    elsif type == 'choices'
      

      puts '99999999999999999999'
      puts message
      puts '99999999999999999999'

      bnt = []
      for i in 0..qtd_btn-1 do
        if qtd_btn > 3
          bnt[i] = {
            id:"#{botao[i]['value']}",
            title:"#{botao[i]['value'].capitalize()}",
            description:"#{botao[i]['title']}"
          }
        else
          bnt[i] = {
            id:"#{botao[i]['value']}",
            title:"#{botao[i]['value'].capitalize()}"
          }
        end
        
      end

      if qtd_btn > 3
        body = { 
          from: "wild-newsprint",
          to: phone,
          # contents: [{"type":"file","fileUrl":"#{link}", "fileCaption":"#{message}"}]
          contents: [
            {
            type:"list",
            header:"#{message}",
            body:"⠀⠀⠀⠀⠀⠀⠀⠀⠀",
            footer:"",
            button:"Clique aqui",
            sections:[
              {
              title:"Section Title",
              rows:
  
                bnt
  
  
                
              }
             ]
            }
          ]
        }
      else
        body = {
          from: "wild-newsprint",
          to: phone,
          contents: [
            {
            type: "button",
            header: {
            type: "text",
            text: "#{message}"
            },
            body: "⠀⠀⠀⠀⠀⠀⠀⠀⠀",
            footer: "⠀⠀⠀⠀⠀⠀⠀⠀⠀",
                buttons: 
                bnt
            }
           ]
          }
      end

      
    else

      
      body = { 
        from: "wild-newsprint",
        to: phone,
        contents: [{"type":"file","fileUrl":"#{link}", "fileCaption":"#{message}"}]
       
      }
      
    end

    
    
    puts 'body'
    puts body.to_json
    
    result = HTTParty.post(url, 
      :body => body.to_json,
      :headers => { 'Content-Type' => 'application/json', 'X-API-TOKEN' => 'YAbu_lrft2azIjc3TYlH6jrs7AD4I-_I1vJh' } )

      if type != 'text'
        sleep 2
      end

      puts result

      result
  
end

def human_false(subscriptionId, message, client, name, phone)

  result = post_bot(subscriptionId, message)       
  puts "--------------------------------result"
  puts result

      count_result = result['responses'].length
     
      human = false
      puts 'teste ok'
      puts count_result

      qt = ''

    for msg in 0..count_result-1 do
      puts "-----------"
      puts "mensagem do bot: #{result['responses'][msg]['text']} - Para o número : #{phone}"
      puts "-----------"     

      # salva a mensagem do usuário
      create_message(client.id, result['responses'][msg]['text'], 'bot')


   
      if result['responses'][msg]['image'].present? && result['responses'][msg]
        link = result['responses'][msg]['image']

        title = result['responses'][msg]['title'].gsub!"<br>", "\n"
        
        whats =  post_whats(title, phone, 'image/jpeg', link, '', '')
        
        
      elsif result['responses'][msg]['text'].present? 
        
        
        type = 'text'
        botao = []
        qtd_btn = 0
        if result['responses'][msg]['skill'].present?
          qtd_btn = result['responses'][msg]['choices'].length
          type = 'choices'

          count_botao = result['responses'][msg]['choices'].length

          puts result['responses'][msg]
     
         puts "botao tem #{count_botao}"
          # botao = result['responses'][msg]['choices']
          
          #     for qtd_btn in 0..count_botao-1 do
              
               
          #         botao[qtd_btn] = {                    
          #           "id": "#{result['responses'][msg]['choices'][qtd_btn]['value']}"
          #           "title": "#{result['responses'][msg]['choices'][qtd_btn]['title']}"
          #           "description": "#{result['responses'][msg]['choices'][qtd_btn]['title']}"
          #           }
         
          #     end
          #   puts 'botao'
        end
        

        whats =  post_whats(result['responses'][msg]['text'], phone, type, '', result['responses'][msg]['choices'], qtd_btn)
  
      elsif result['responses'][msg]['audio'].present?
        link = result['responses'][msg]['audio'].gsub!"http://localhost:3000", "https://5dbc-177-37-173-214.ngrok.io"
                whats =  post_whats(result['responses'][msg]['text'], phone, 'audio/mpeg', link, '', '')
        
  
      elsif result['responses'][msg]['video'].present?
        link = result['responses'][msg]['video'].gsub!"http://localhost:3000", "https://5dbc-177-37-173-214.ngrok.io"
                whats =  post_whats(result['responses'][msg]['text'], phone, 'video/mp4', link, '', '')

                
        
  
      end
   

    
      
        # whats =  post_whats(result['responses'][msg]['text'], phone)
        # puts '**********************'
        # puts whats
        # puts '**********************'
      

    

    end


    if (human == true)

      update_client(client.id, phone, message, name, subscriptionId, client)
    end
  

    result
end
  

  def Whats_params

      params.permit(:subscriptionId, :message, :visitor, :contents)
  end
    
end
