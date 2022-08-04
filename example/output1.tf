output "id" {
  value       = module.label1.id
  description = "ID, restricted to `prefix_length_limit` if set otherwise, full ID"
}

output "id_full" {
  value       = module.label1.id_full
  description = "Full ID, not restricted to prefix_length_limit"
}

output "enabled" {
  value       = module.label1.enabled
  description = "A boolean to enable or disable tagging/labeling module"
}

output "environment" {
  value       = module.label1.environment
  description = "Environment name passed to module such as us-east-1, ap-west-1, eu-central-1"
}

output "project_name" {
  value       = module.label1.project_name
  description = "The project name or organization name, could be fullName or abbreviation such as `ex`"
}

output "name" {
  value       = module.label1.name
  description = "The name of the service/solution such as vpc, ec2"
}

output "tags" {
  value       = module.label1.tags
  description = "Tags, Tags to be generated by this module which can be access by module.<name>.tags e.g. map('CostCenter', 'Production')"
}

output "additional_tags" {
  value       = module.label1.additional_tags
  description = "Additional Tags, tags which can be accessed by module.<name>.tags_as_list not added to <module>.<name>.<tags>"
}

output "delimiter" {
  value       = module.label1.delimiter
  description = "Delimiter to be used between `project_name`, `environment`, `region` and, `name`."
}

output "regex_substitute_chars" {
  value       = module.label1.regex_substitute_chars
  description = "Regex, to be used for id substitution in case of using `prefix_length_limit`"
}

output "prefix_order" {
  value       = module.label1.prefix_order
  description = "an ordered list of strings that forms the `ID` attribute"
}

output "attributes" {
  value       = module.label1.attributes
  description = "A list of attributes e.g. `private`, `shared`, `cost_center`"
}

output "context" {
  value       = module.label1.context
  description = "A context to be used as an input for other modules"
}

output "random_string" {
  value       = module.label1.random_string
  description = "A random string, used in `id` and `id_short` in case of setting `prefix_lenght_limit`"
}