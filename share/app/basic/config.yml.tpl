appname: [%APP%]
charset: 'UTF8'
content_type: "text/html"
template: "template_toolkit"

session: 'YAML'

engines:
  template:
    template_toolkit:
      encoding: 'utf-8'
  serializer:
    json:
      pretty: 1
