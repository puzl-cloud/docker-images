#!/usr/bin/env python3

import click
import json
import os
from jinja2 import Template


def read_json_file(path):
    try:
        with open(path) as input_file:
            result = json.load(input_file)
        input_file.close()

    except Exception as e:
        print("Can not read json file " + str(path) + " !")
        raise e

    return result


def read_jinja_template(path):
    try:
        with open(path) as input_file:
            template = Template(input_file.read())
        input_file.close()

    except Exception as e:
        print("Can not read template file " + str(path) + " !")
        raise e

    return template


def render_readme(j2_template, meta, image_name, output):
    template = read_jinja_template(j2_template)
    metadata = read_json_file(meta)

    variables = dict()
    variables["image_name"] = image_name
    variables["image_description"] = metadata["description"]
    source_image = metadata["sourceImage"]
    if len(source_image.split('/')) == 1:
        variables["source_image_name"] = source_image
        variables["source_image_link"] = f"https://hub.docker.com/_/{source_image}"
    else:
        variables["source_image_name"] = source_image.split('/')[1]
        variables["source_image_link"] = f"https://hub.docker.com/r/{source_image}"

    if "interpreters" in metadata and metadata["interpreters"]:
        variables["interpreters"] = metadata["interpreters"]

    if "packages" in metadata and metadata["packages"]:
        variables["installed_packages"] = dict()
        for package in metadata["packages"]:
            if package["type"] not in variables["installed_packages"]:
                variables["installed_packages"][package["type"]] = list()
            if package not in variables["installed_packages"][package["type"]]:
                variables["installed_packages"][package["type"]].append(package)

    try:
        rendered_template = template.render(**variables)
        print(f"Readme file for {image_name} image is rendered to {output}")
    except Exception as e:
        print("Invalid json template")
        raise e

    try:
        with open(output, "w") as out_file:
            out_file.write(rendered_template)
    except Exception as e:
        print("Unable to render output")
        raise e

def auto_generate_readmes(base_dir="images", j2_template_path="globals/readme.j2"):
    for root, dirs, files in os.walk(base_dir):
        if 'metadata.json' in files:
            meta_path = os.path.join(root, 'metadata.json')
            # Extracting the top-level directory name
            image_name = os.path.basename(os.path.dirname(root) if os.path.dirname(root) != base_dir else root)
            output_path = os.path.join(root, 'README.md')
            render_readme(j2_template_path, meta_path, image_name, output_path)

@click.command()
@click.option('--template', '-t', help="Path to Jinja template file", default="globals/readme.j2")
@click.option('--base-dir', '-b', help="Base directory to scan", default="images")
def exec_command(template, base_dir):
    return auto_generate_readmes(base_dir, template)

if __name__ == '__main__':
    exec_command()
