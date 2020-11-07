#!/usr/bin/env python3

import click
import json
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


@click.command()
@click.option('--template', '-t', help="Path to Jinja template file", required=True)
@click.option('--meta', '-m', help="Path to json file with Docker image metadata", required=True)
@click.option('--image-name', '-n', help="Name of Docker image", required=True)
@click.option('--output', '-o', help="Path to rendered output file", required=False, default="README.md")
def exec_command(template, meta, image_name, output="readme.md"):
    return render_readme(template, meta, image_name, output)


if __name__ == '__main__':
    exec_command()
