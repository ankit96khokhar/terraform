import sys
import yaml
import json

# -----------------------------
# Generic recursive validator
# -----------------------------
def validate_block(schema_block, data_block, path=""):
    if not isinstance(schema_block, dict):
        return

    if not isinstance(data_block, dict):
        print(f"Invalid type at {path}, expected dict")
        sys.exit(1)

    # Required fields
    for key, rules in schema_block.items():
        if isinstance(rules, dict) and rules.get("required") is True:
            if key not in data_block:
                print(f"Missing required key: {path}.{key}")
                sys.exit(1)

    # Unknown fields
    for key in data_block:
        if key not in schema_block:
            print(f"Unknown key found: {path}.{key}")
            sys.exit(1)

    # Field validation
    for key, value in data_block.items():
        rules = schema_block[key]
        field_type = rules.get("type")

        if field_type == "string" and not isinstance(value, str):
            print(f"Invalid type at {path}.{key}, expected string")
            sys.exit(1)

        if field_type == "number" and not isinstance(value, (int, float)):
            print(f"Invalid type at {path}.{key}, expected number")
            sys.exit(1)

        if field_type == "boolean" and not isinstance(value, bool):
            print(f"Invalid type at {path}.{key}, expected boolean")
            sys.exit(1)

        if field_type == "map" and not isinstance(value, dict):
            print(f"Invalid type at {path}.{key}, expected map")
            sys.exit(1)

        if "allowed" in rules and value not in rules["allowed"]:
            print(
                f"Invalid value at {path}.{key}: {value}. "
                f"Allowed values: {rules['allowed']}"
            )
            sys.exit(1)

        # Recursive validation for nested maps
        if field_type == "map" and "schema" in rules:
            for sub_key, sub_val in value.items():
                validate_block(
                    rules["schema"],
                    sub_val,
                    f"{path}.{key}.{sub_key}"
                )


# -----------------------------
# Main validation + tfvars gen
# -----------------------------
def validate_and_generate(schema_file, tenant_file, output_tfvars):
    with open(schema_file) as sf:
        schema = yaml.safe_load(sf)

    with open(tenant_file) as tf:
        tenant = yaml.safe_load(tf)

    if not isinstance(tenant, dict):
        print("Tenant YAML must be a dictionary")
        sys.exit(1)

    # -----------------------------
    # Step 1: Top-level validation
    # -----------------------------
    required_keys = []
    allowed_keys = []

    for key, value in schema.items():
        if isinstance(value, dict):
            allowed_keys.append(key)
            if value.get("required") is True:
                required_keys.append(key)

    for key in required_keys:
        if key not in tenant:
            print(f"Missing required top-level key: {key}")
            sys.exit(1)

    for key in tenant:
        if key not in allowed_keys:
            print(f"Invalid top-level key: {key}")
            sys.exit(1)

    # -----------------------------
    # Step 2: env & region
    # -----------------------------
    if tenant["env"] not in schema["env"]["allowed"]:
        print(f"Invalid env: {tenant['env']}")
        sys.exit(1)

    if tenant["region"] not in schema["region"]["allowed"]:
        print(f"Invalid region: {tenant['region']}")
        sys.exit(1)

    # -----------------------------
    # Step 3: Services catalog
    # -----------------------------
    services = tenant["services"]
    if not isinstance(services, dict):
        print("services must be a dictionary")
        sys.exit(1)

    allowed_services = schema["services"].keys()

    for svc, svc_data in services.items():
        if svc not in allowed_services:
            print(f"Service not allowed: {svc}")
            sys.exit(1)

        if not isinstance(svc_data, dict):
            print(f"Service {svc} config must be a dict")
            sys.exit(1)

        if "enabled" not in svc_data or not isinstance(svc_data["enabled"], bool):
            print(f"Service {svc} must have boolean 'enabled'")
            sys.exit(1)

    # -----------------------------
    # Step 4: Generic service validation
    # -----------------------------
    for svc, svc_data in services.items():
        if svc_data["enabled"] is True:
            svc_schema = schema["services"][svc]
            if "config" in svc_schema:
                if "config" not in svc_data:
                    print(f"Missing config for enabled service: {svc}")
                    sys.exit(1)

                validate_block(
                    svc_schema["config"],
                    svc_data["config"],
                    f"services.{svc}.config"
                )

    # -----------------------------
    # Step 5: Generate tfvars JSON
    # -----------------------------
    tfvars = {
        "tenant": tenant["tenant"],
        "environment": tenant["env"],
        "region": tenant["region"],
    }

    if "description" in tenant:
        tfvars["description"] = tenant["description"]

    tfvars["services"] = {}

    for svc, svc_data in services.items():
        if svc_data["enabled"] is True:
            tfvars["services"][svc] = svc_data.get("config", {})


    with open(output_tfvars, "w") as out:
        json.dump(tfvars, out, indent=2)

    print(f"✅ Validation passed. tfvars generated at {output_tfvars}")


# -----------------------------
# Entry point
# -----------------------------
if __name__ == "__main__":
    if len(sys.argv) != 4:
        print("Usage: python validate_and_generate_tfvars.py <schema.yaml> <tenant.yaml> <output.tfvars.json>")
        sys.exit(1)

    validate_and_generate(sys.argv[1], sys.argv[2], sys.argv[3])
