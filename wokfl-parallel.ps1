workflow Test-ParallelForeach
{
  param
  (
    [String[]]
    $ComputerName
  )

  foreach -parallel -throttlelimit 8 ($Machine in $ComputerName)
  {
    "Begin $Machine"
    Start-Sleep -Seconds (Get-Random -min 3 -max 5)
    "End $Machine"
  }
}

$list = 1..20

Test-ParallelForeach -ComputerName $list #| Out-GridView