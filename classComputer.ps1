class Computer{
	[string]$Name
	[string]$Description
	[int]$Reboots
	
	
	# constructor
	Computer(){
		
	}
	
	Computer($ComputerName, $ComputerDescription){
		$this.Name = $ComputerName
		$this.Description = $ComputerDescription
	}
	
	AddReboot(){
		$This.Reboots++
	}
}

$cmp =  [Computer]::new()

$cmp.Name = "Asher"
$cmp.Description = "Sandler"
$cmp.AddReboot()

$cmp1 = [Computer]::New("Simcha","Computer of Simcha")
$cmp
$cmp1
$cmp1.GetType()


