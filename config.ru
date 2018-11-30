# encoding: UTF-8
$:.unshift File.expand_path(File.dirname(__FILE__))
require 'app'
require 'coderay'
require 'rack/contrib'

require File.dirname(__FILE__) + '/lib/code_highlighter'
require File.dirname(__FILE__) + '/lib/redirects'

use Redirects, {
  static: {
    '/es/configuracion/formas-de-envio' => '/es/configuracion/opciones-de-envio',
    '/es/configuracion/medios-de-pago' => '/es/formas-de-pago',
    '/es/configuracion/servicios' => '/es/componentes-e-integraciones',
    '/es/configuracion/seo' => '/es/dominio-y-seo',
    '/es/tutoriales/comentar-el-codigo-fuente' => '/es/cuenta/desactivar-compras',
    '/es/tutoriales/favoritos' => '/es/pedidos/acceso-rapido',
    '/es/administracion' => '/es',
    '/es/tutoriales' => '/es',
    '/es/componentes' => '/es/componentes-e-integraciones'
  },
  regex: {
    # /^\/es\/diseno\/(.*)/ => '/es/diseno'
  }
}

use Codehighlighter
use Rack::JSONP
run App
