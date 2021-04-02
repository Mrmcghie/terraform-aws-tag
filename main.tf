locals {
  defaults = {
    prefix_order = ["environment", "project_name", "region", "name"]
    regex_substitute_chars = "/[^a-zA-Z0-9]/"
    delimiter = "-"
    replacement = ""
    prefix_length_limit = 0
    random_length = 5
    tag_key_case = "title"
    tag_value_case = "lower"
  }

  replacement = local.defaults.replacement
  random_length = local.defaults.random_length

  input = {
    enabled = var.enabled == null ? var.context.enabled : var.enabled
    region = var.region == null ? var.context.region : var.region
    project_name = var.project_name == null ? var.context.project_name : var.project_name
    environment = var.environment == null ? var.context.environment : var.environment
    name = var.name == null ? var.context.name : var.name
    tags = merge(var.context.tags, var.tags)
    delimiter = var.delimiter == null ? var.context.delimiter : var.delimiter
    additional_tags = merge(var.additional_tags, var.context.additional_tags)
    prefix_order  = var.prefix_order == null ? var.context.prefix_order : var.prefix_order
    prefix_length_limit = var.prefix_length_limit == null ? var.context.prefix_length_limit : var.prefix_length_limit
    regex_substitute_chars  = var.regex_substitute_chars == null ? var.context.regex_substitute_chars : var.regex_substitute_chars
    tag_key_case = var.tag_key_case == null ? var.context.tag_key_case : var.tag_key_case
    tag_value_case = var.tag_value_case == null ? var.context.tag_value_case : var.tag_value_case
    attributes = compact(distinct(concat(coalesce(var.context.attributes, []), coalesce(var.attributes, []))))
  }

  enabled = local.input.enabled
  regex_substitute_chars = coalesce(local.input.regex_substitute_chars, local.defaults.regex_substitute_chars)

  # normalizing prefixes
  string_prefix_names = ["environment", "project_name", "region", "name"]
  normalized_prefixes = {
    for k in local.string_prefix_names : k => local.input[k] == null ? "" : replace(local.input[k], local.regex_substitute_chars , local.replacement )
  }
  tag_key_case = local.input.tag_key_case == null ? local.defaults.tag_key_case : local.input.tag_key_case
  tag_value_case = local.input.tag_value_case == null ? local.defaults.tag_value_case : local.input.tag_value_case

  formatted_prefix_case = {
    for k in local.string_prefix_names : k => local.tag_value_case == "none" ? local.normalized_prefixes[k] :
    local.tag_value_case == "title" ? title(lower(local.normalized_prefixes[k])) : local.tag_value_case == "upper" ? upper(local.normalized_prefixes[k]) : lower(local.normalized_prefixes[k])
  }

  normalized_attributes = [ for l in local.input.attributes : replace(l, local.regex_substitute_chars,local.replacement )]
  formatted_attributes = [ for l in local.normalized_attributes :
          (
                  local.tag_value_case == "none" ? l : local.tag_value_case == "upper" ? upper(l) : local.tag_value_case == "title" ? title(l) : lower(l)
          )]

  environment = local.formatted_prefix_case["environment"]
  project_name = local.formatted_prefix_case["project_name"]
  region = local.formatted_prefix_case["region"]
  name = local.formatted_prefix_case["name"]

  delimiter = local.input.delimiter == null ? local.defaults.delimiter : local.input.delimiter
  prefix_length_limit = local.input.prefix_length_limit == null ? local.defaults.prefix_length_limit : coalesce(local.input.prefix_length_limit, local.defaults.prefix_length_limit)
  prefix_order = local.input.prefix_order == null ? local.defaults.prefix_order : coalescelist(local.input.prefix_order, local.defaults.prefix_order)

  additional_tag = merge(var.context.additional_tags, var.additional_tags)
  tags_structure = {
    name = local.id
    region = local.region
    project_name = local.project_name
    environment = local.environment
    attributes = join(local.delimiter, local.formatted_attributes)
  }

  generated_tags = {
    for k in keys(local.tags_structure) : local.tag_key_case == "upper" ? upper(k) : local.tag_key_case == "lower" ? lower(k) : title(k) => local.tags_structure[k] if length(local.tags_structure[k]) > 0
  }

  tags = merge(local.generated_tags, local.input.tags)

  # Forming the `id` attribute/variable
  id_structure = {
    environment = local.environment
    project_name = local.project_name
    region = local.region
    name = local.name
  }

  labels = [for l in local.prefix_order : local.id_structure[l] if length(local.id_structure[l]) > 0]
  id_full = join(local.delimiter, local.labels)
  delimiter_length = length(local.delimiter)

  id_truncated_length_limit = local.prefix_length_limit - (local.delimiter_length + local.random_length)
  id_truncated = local.id_truncated_length_limit <=0 ? "" : "${trimsuffix(substr(local.id_full, 0, local.id_truncated_length_limit), local.delimiter)}${local.delimiter}"
  id_random = random_string.this.result
  id_short = substr("${local.id_truncated}${local.id_random}",0 ,local.prefix_length_limit )
  id = local.prefix_length_limit != 0 && length(local.id_full) > local.prefix_length_limit ? local.id_short : local.id_full

    # Context of this label to pass to other label modules
  outputs = {
    enabled             = local.enabled
    name                = local.name
    project_name           = local.project_name
    environment         = local.environment
    region               = local.region
    delimiter           = local.delimiter
    tags                = local.tags
    additional_tag  = local.additional_tag
    prefix_order         = local.prefix_order
    regex_substitute_chars = local.regex_substitute_chars
    prefix_length_limit     = local.prefix_length_limit
    tag_key_case      = local.tag_key_case
    tag_value_case    = local.tag_value_case
  }
}
