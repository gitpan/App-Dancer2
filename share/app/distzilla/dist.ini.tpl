name = [%APP%]
license = Perl_5
copyright_holder = YOUR_NAME <YOUR_EMAIL>
copyright_year = [%CURRENT_YEAR%]

[@Author::Celogeek]
-remove=UploadToCPAN
;Release
[Run::Release]
run = scripts/deploy.sh %s

