class OseApi
  require 'net/https'
  
  def initialize(url, port, get_dossier_path, key)
    @url  = url
    @port = port
    @get_dossier_path = get_dossier_path
    @key = key
  end
  
  def find_by_nom(query)
    return self.find_by 'nom', query
  end
  
  def find_by_prenom(query)
    return self.find_by 'prenom', query
  end
  
  def find_by_projet_service(query)
    return self.find_by 'projet_service', query
  end
  
  def find_by_login(query)
    return self.find_by 'login', query
  end
  
  def find_by(method, search)
    http = Net::HTTP.new(@url, @port)
    http.use_ssl = true
    http.start do |http|
      query = @get_dossier_path + '?api_key=' + @key + '&' + method + '=' + CGI.escape(search)
      request = Net::HTTP::Get.new(query)
      
      # Http authentication if required
      #request.basic_auth '__login__', '__password__'
      
      response = http.request(request)      
      h_rsp = XmlSimple.xml_in(response.body)
      
      if h_rsp['status'].nil?
        return { 'has_answers' => false, 'answers' => nil, 'query_type' => method, 'status' => 'ko', 'api_message' => h_rsp.to_yaml }
      else
        if h_rsp['data'][0]['recordcount'].to_i == 0
          return { 'has_answers' => false, 'answers' => nil, 'query_type' => method, 'status' => 'ok'}
        else
          return { 'has_answers' => true, 'answers' => h_rsp['data'][0]['dossier'], 'query_type' => method, 'status' => 'ok'}
        end
      end
    end
  end
  
end