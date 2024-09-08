import os
import json

def generate_api_snippets():
    path = 'shared.code-snippets'

    with open(path, 'w') as p_js:
        # Todo- hacer que lea shared y los #include
        scripts = ['shared', 'Json', 'Language', 'PlayerFuncs', 'Utility', 'Hooks' ]

        p_js.write("{\n")
        b_coma = False

        for name in scripts:
            file_path = name + '.as'
            with open(file_path, 'r') as p_script:
                label = ''
                prefix = ''
                body = ''
                description = ''
                classes = ''
                on_comment = False

                for line in p_script:
                    line = line.strip()

                    if line.startswith("// prefix:") or line.startswith("// description:") or line.startswith("// body:"):
                        on_comment = True
                        if line.startswith("// prefix:"):
                            prefix = line[line.find("// prefix:") + len("// prefix:"):].strip()
                        if line.startswith("// description:"):
                            description = line[line.find("// description:") + len("// description:"):].strip()
                        if line.startswith("// body:"):
                            classes = line[line.find("// body:") + len("// body:"):] + '.'
                    elif on_comment:
                        label = line
                        body = line

                    if body:
                        first_space_index = body.find(" ")
                        s = body[first_space_index + 1:]
                        open_paren_index = s.find("(")
                        s = s[:open_paren_index + 1]

                        if "()" not in body:
                            var = body[first_space_index + 1:]
                            var = var[len(s):]
                            close_paren_index = var.find(")")
                            var = var[:close_paren_index - 1]
                            str_vars = var.split(",")
                            s += ' '

                            for i, var in enumerate(str_vars):
                                var = var.strip()
                                s += f'${{{i + 1}:{var}}}'

                                if len(str_vars) > 1 and i < len(str_vars) - 1:
                                    s += ', '
                            s += ' '
                        s += ')'
                        body = classes.strip() + s

                    if label and on_comment and prefix and body and description:
                        if b_coma:
                            p_js.write(",\n")

                        b_coma = True
                        p_js.write(f"\t\"{label}\":\n")
                        p_js.write("\t{\n")
                        p_js.write("\t\t\"prefix\":\n")
                        p_js.write("\t\t[\n")
                        p_js.write(f"\t\t\t{prefix}\n")
                        p_js.write("\t\t],\n")
                        p_js.write(f"\t\t\"body\": \"{body}\",\n")
                        description = description.strip()
                        p_js.write(f"\t\t\"description\": \"{description}\"\n")
                        p_js.write("\t}")

                        label = prefix = body = description = classes = ''
                        on_comment = False
        p_js.write("\n}\n")

def main():
    generate_api_snippets()

if __name__ == "__main__":
    main()