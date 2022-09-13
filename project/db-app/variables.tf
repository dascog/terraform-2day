variable "aws_region" {
   description = "AWS region code for hosting this instance" 
   type = string
   default = "eu-west-1"
}

variable "instance_type" {
  description = "Type of EC2 instance to use"
  type        = string
  default     = "t2.micro"
}

variable "prefix" {
    description = "A prefix for resource tags"
    type = string
    default = "dsg"
}

variable "jarfile_name" {
  description = "the name of the jarfile to run"
  type = string
  default = "CompactDiscRestWithDatabase"
}

variable "jarfile_url" {
  description = "The URL of the jarfile to download"
  type = string
  default = "https://tinyurl.com/CompactDiscRestWithDatabase"

}