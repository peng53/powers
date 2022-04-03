$MySource = @"
    public class MyClass2 {
        public int x;
        public MyClass2(int y){
            x = y;
        }
        public int gx(){
            System.Console.WriteLine(x);
            return x;
        }
    }
"@
Add-Type -TypeDefinition $MySource
# call by [MyClass2]::gx
$p = new-object MyClass2 10