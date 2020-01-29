function get_value([String] $counter_name, [int16] $element_number)
{
    $output               = ""
    $previous_error_count = $Error.Count
    $counter              = Get-Counter -Counter $counter_name -ErrorAction SilentlyContinue
    
    if ($Error.Count -eq $previous_error_count) {
        $output = ("" + $counter.Readings).Split(":")[$element_number].Trim()
    }

    return $output
}


function ex_perfcounter()
{
  $smtp_receive_average_bytes_per_message                    = get_value "\MSExchangeTransport SMTPReceive(_total)\Average bytes/message" 1
  $smtp_receive_messages_received_per_second                 = get_value "\MSExchangeTransport SMTPReceive(_total)\Messages Received/sec" 1
  $smtp_send_messages_sent_per_second                        = get_value "\MSExchangeTransport SmtpSend(_total)\Messages Sent/sec" 1
  $store_driver_inbound_local_delivery_calls_per_second      = get_value "\MSExchange Store Driver\Inbound: LocalDeliveryCallsPerSecond" 2
  #$store_driver_inbound_message_delivery_attempts_per_second = get_value "\MSExchange Store Driver\Inbound: MessageDeliveryAttemptsPerSecond" 2
  #$store_driver_inbound_recipients_delivered_per_second      = get_value "\MSExchange Store Driver\Inbound: Recipients Delivered Per Second" 2
  $store_driver_outbound_submitted_mail_items_per_second     = get_value "\MSExchange Store Driver\Outbound: Submitted Mail Items Per Second" 2

  $date = (Get-Date -format "yyyy MMM %d HH:mm:ss")
  $output_entry = "$date SMTPReceive_AverageBytesPerMessage=`"$smtp_receive_average_bytes_per_message`" SMTPReceive_MessagesReceivedPerSecond=`"$smtp_receive_messages_received_per_second`" SmtpSend_MessagesSentPerSecond=`"$smtp_receive_messages_received_per_second`" StoreDriver_Inbound_LocalDeliveryCallsPerSecond=`"$store_driver_inbound_local_delivery_calls_per_second`""

  # Verify the output directory exists.
  $logs_directory = ".\\logs"
  if (!(Test-Path $logs_directory)) {
    $tempPath = New-Item -ItemType directory -Path $logs_directory
  }

  #deleting the file if it exists already 
  if ( Test-Path $logs_directory\exchange_perfmon_counters.log ){
	Remove-Item $logs_directory\exchange_perfmon_counters.log
  }
  write-host "Out  $output_entry"
  Out-File -FilePath ([string]::Format("{0}\\exchange_perfmon_counters.log", $logs_directory)) -Append -Force -InputObject $output_entry -Encoding "UTF8"
}

#ex_perfcounter