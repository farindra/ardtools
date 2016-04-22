<?php
$result = array();
$result_dns = '';


if (isset($_POST['domain']) && !empty($_POST['domain'])) {
$geo = json_decode(str_replace(' ','', file_get_contents('https://mxtoolbox.com/api/v1/lookup/a/'.$_POST['domain'].'?Authorization=eac945e3-2c86-48d2-a436-990de58a881b')));
//echo $geo->ReportingNameServer;
//print_r($geo);
//echo strlen($geo->ReportingNameServer);

  if (strlen($geo->ReportingNameServer)!=0) {
    $result_dns = ' <label class="col-md-3 control-label" for="textinput">Hasil -></label>  
                    <div class="col-md-9">
                      <div class="input-group">
                        <span class="input-group-addon">DNS</span>
                        <input id="dns_dns" name="dns_dns" class="form-control" placeholder="" type="text" value="'.$geo->ReportingNameServer.'">
                      </div>
                      <div class="input-group">
                        <span class="input-group-addon">IP</span>
                        <input id="dns_ip" name="dns_ip" class="form-control" placeholder="" type="text" value="'.$geo->Information[0]->IPAddress.'">
                      </div>
                      <div class="input-group">
                        <span class="input-group-addon">Host</span>
                        <input id="dns_host" name="dns_host" class="form-control" placeholder="" type="text" value="'.gethostbyaddr($geo->Information[0]->IPAddress).'">
                      </div>
                    </div>
                  ';
  }

} else {
//$geo = 'Nothing found or Domain Invalid';
}


?>

<!DOCTYPE html>
<html lang="en">
  <head>
    <title>The Hoki - Ard Tools</title>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1">
    <link rel="stylesheet" href="http://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/css/bootstrap.min.css">
    <script src="https://ajax.googleapis.com/ajax/libs/jquery/1.12.0/jquery.min.js"></script>
    <script src="http://maxcdn.bootstrapcdn.com/bootstrap/3.3.6/js/bootstrap.min.js"></script>
  </head>
<body>
  <div class="container">
    <img class="img-responsive" src="http://ardhosting.com/img/logo.png" alt="logo">
    <div class="row">
      <form class="col-md-4 form-horizontal" method="post">
        <fieldset>
          <!-- Form Name -->
          <legend>DNS A Lookup</legend>

          <!-- Text input-->
          <div class="form-group">
            <label class="col-md-3 control-label" for="textinput">Domain</label>  
            <div class="col-md-9">
              <div class="input-group">
                <input id="textinput" name="domain" type="text" placeholder="ardhosting.com" class="form-control input-md" required="">
                <span class="input-group-btn">
                  <button id="btn_dns" name="btn_dns" class="btn btn-primary">
                    <span class="glyphicon glyphicon-search"></span>
                  </button>
                </span>
              </div>
            </div>

          </div>

          <div class="form-group">         
           <?php echo $result_dns;?>
         </div>

        </fieldset>
      </form>
      
    </div>
  </div>
</body>
</html>

