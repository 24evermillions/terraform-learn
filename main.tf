////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
provider "aws" {                                    //Nana Section 4 Video 17   
    region = "eu-west-2"                            //Nana Section 4 Video 17   
}



//VARIABLES "We create our variables which we will assign at the end"

variable vpc_cidr_block {}                          //Nana Section 4 Video 17
variable subnet_cidr_block {}                       //Nana Section 4 Video 17
variable avail_zone {}                              //Nana Section 4 Video 17
variable env_prefix {}                              //Nana Section 4 Video 17
variable my_ip {}                                   //Nana Section 4 Video 21
variable instance_type {}                           //Nana Section 4 Video 23
variable public_key_location {}                     //Nana Section 4 Video 24


//VPC RESOURCE

resource "aws_vpc" "myapp-vpc" {                    //Nana Section 4 Video 17
    cidr_block = var.vpc_cidr_block                 //Nana Section 4 Video 17
    tags = {                                        //Nana Section 4 Video 17
        Name: "${var.env_prefix}-vpc"               //Nana Section 4 Video 17     
    }
}

//SUBNET RESOURCE

resource "aws_subnet" "myapp-subnet-1"{             //Nana Section 4 Video 17   
    vpc_id = aws_vpc.myapp-vpc.id                   //Nana Section 4 Video 17   
    cidr_block = var.subnet_cidr_block              //Nana Section 4 Video 17   
    availability_zone = var.avail_zone              //Nana Section 4 Video 17   
    tags = {                                        //Nana Section 4 Video 17   
    Name: "${var.env_prefix}-subnet-1"              //Nana Section 4 Video 17   
    }
}

/*
We have the availability zone as a variable also set
and we can decide in which az of the region the subnet will be created 
and the EC2 will be deployed in. And lets also change the name tag 

We change the name tag so for every component that were 
creating lets give it a prefix of the environment 
that its going to be deployed in. So in a development environment
components will have a dev prefix and so on. So we create a variable
called env_prefix {}. 

So what we do is string interpolation thats basically having variable value 
and string glued togetherso were going to something like dev-vpc and this dev 
will be basicallya prefix that is be set as a variable and in order to use 
this variable value were going to do ${} so using the variable outside 
not inside the string or inside the quotes is var.variable name
If we want to use a variable inside a string because we want to glue it 
or put it together with another string we are using ${var.env_prefix}-vpc
*/


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


//ROUTE TABLE RESOURCE

/*
resource "aws_route_table" "myapp-route-table"{                      //Nana Section 4 Video 18  
    vpc_id = aws_vpc.myapp-vpc.id                                    //Nana Section 4 Video 18   

    route {                                                          //Nana Section 4 Video 18                                  
      cidr_block = "0.0.0.0/0"                                       //Nana Section 4 Video 18
      gateway_id = aws_internet_gateway.myapp-igw.id                 //Nana Section 4 Video 18
    }
    tags = {                                                         //Nana Section 4 Video 18
      Name: "${var.env_prefix}-rtb"                                  //Nana Section 4 Video 18
    }

}
*/

//INTERNET GATEWAY RESOURCE

resource "aws_internet_gateway" "myapp-igw" {                        //Nana Section 4 Video 18
    vpc_id = aws_vpc.myapp-vpc.id                                    //Nana Section 4 Video 18    
    tags = {                                                         //Nana Section 4 Video 18                                                 
      Name: "${var.env_prefix}-igw"                                  //Nana Section 4 Video 18 
    }
}

/////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//ROUTE TABLE ASSOCIATION RESOURCE

/*
resource "aws_route_table_association" "a-rtb-subnet"{               //Nana Section 4 Video 19
    subnet_id = aws_subnet.myapp-subnet-1.id                         //Nana Section 4 Video 19
    route_table_id = aws_route_table.myapp-route-table.id            //Nana Section 4 Video 19
}
*/

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//DEFAULT ROUTE RESOURCE

resource "aws_default_route_table" "main-rtb"{                                  //Nana Section 4 Video 20
    default_route_table_id = aws_vpc.myapp-vpc.default_route_table_id           //Nana Section 4 Video 20

    route {                                                                     //Nana Section 4 Video 20                                  
      cidr_block = "0.0.0.0/0"                                                  //Nana Section 4 Video 20
      gateway_id = aws_internet_gateway.myapp-igw.id                            //Nana Section 4 Video 20
    }
    tags = {                                                                    //Nana Section 4 Video 20
      Name: "${var.env_prefix}-main-rtb"                                        //Nana Section 4 Video 20
    }

}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//SECURITY GROUP RESOURCE

  //resource "aws_security_group" "myapp-sg"{               //Nana Section 4 Video 21
    resource "aws_default_security_group" "default_sg"{     //Nana Section 4 Video 21
  //name = "myapp-sg"                                       //Nana Section 4 Video 21
    vpc_id = aws_vpc.myapp-vpc.id                           //Nana Section 4 Video 21

    ingress {                                               //Nana Section 4 Video 21
        from_port =22                                       //Nana Section 4 Video 21
        to_port =22                                         //Nana Section 4 Video 21
        protocol = "TCP"                                    //Nana Section 4 Video 21
        cidr_blocks = [var.my_ip]                           //Nana Section 4 Video 21
    }

    ingress {                                               //Nana Section 4 Video 21
        from_port =8080                                     //Nana Section 4 Video 21
        to_port =8080                                       //Nana Section 4 Video 21
        protocol = "TCP"                                    //Nana Section 4 Video 21
        cidr_blocks = ["0.0.0.0/0"]                         //Nana Section 4 Video 21
    }

    egress {
        from_port =0                                        //Nana Section 4 Video 21
        to_port =0                                          //Nana Section 4 Video 21
        protocol = "-1"                                     //Nana Section 4 Video 21
        cidr_blocks = ["0.0.0.0/0"]                         //Nana Section 4 Video 21
        prefix_list_ids = []  
    }    
        tags = {                                            //Nana Section 4 Video 21                                                 
      // Name: "${var.env_prefix}-sg"                       //Nana Section 4 Video 21 
         Name: "${var.env_prefix}-default-sg"               //Nana Section 4 Video 21
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//EC2 INSTANCE RESOURCE


data "aws_ami" "latest-amazon-linux-image"{                 //Nana Section 4 Video 22 
    most_recent = true                                      //Nana Section 4 Video 22  
    owners = ["amazon"]                                     //Nana Section 4 Video 22 
    filter{                                                 //Nana Section 4 Video 22 
        name = "name"                                       //Nana Section 4 Video 22 
        values = ["amzn2-ami-kernel-*-x86_64-gp2"]          //Nana Section 4 Video 22 
    }
    filter{                                                 //Nana Section 4 Video 22 
        name = "virtualization-type"                        //Nana Section 4 Video 22 
        values = ["hvm"]                                    //Nana Section 4 Video 22 
    } 
}

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//KEY PAIR RESOURCE

resource "aws_key_pair" "ssh-key"{                          //Nana Section 4 Video 24
    key_name = "server-key"                                 //Nana Section 4 Video 24
    public_key = file(var.public_key_location)              //Nana Section 4 Video 24
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

// OUTPUT

output "aws_ami_id"{                                        //Nana Section 4 Video 22 
    value = data.aws_ami.latest-amazon-linux-image.id       //Nana Section 4 Video 22 

}

output "ec2_public_ip"{                                     //Nana Section 4 Video 24 
    value = aws_instance.myapp-server.public_ip             //Nana Section 4 Video 24
}
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

//EC2 INSTANCE RESOURCE 

resource "aws_instance" "myapp-server"{                                         //Nana Section 4 Video 22 

    ami = data.aws_ami.latest-amazon-linux-image.id                             //Nana Section 4 Video 22 
    
    instance_type = var.instance_type                                           //Nana Section 4 Video 23

    subnet_id = aws_subnet.myapp-subnet-1.id                                    //Nana Section 4 Video 23

    vpc_security_group_ids = [aws_default_security_group.default_sg.id]         //Nana Section 4 Video 23

    availability_zone = var.avail_zone                                          //Nana Section 4 Video 23

    associate_public_ip_address = true                                          //Nana Section 4 Video 23

  //key_name = "Test1"                                                          //Nana Section 4 Video 23
    key_name = aws_key_pair.ssh-key.key_name                                    //Nana Section 4 Video 24

 tags = {                                                                       //Nana Section 4 Video 23                                                 
       Name: "${var.env_prefix}-server"                                         //Nana Section 4 Video 23
    }
}
///////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////