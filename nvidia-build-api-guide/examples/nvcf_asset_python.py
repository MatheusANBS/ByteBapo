"""Fluxo genérico de NVCF Asset + upload.

Confirme os nomes dos campos da resposta na documentação atual da API.
"""

from __future__ import annotations

import mimetypes
import os
from pathlib import Path
from typing import Any

import requests


API_ROOT = "https://api.nvcf.nvidia.com/v2/nvcf"


def create_asset(
    api_key: str,
    path: Path,
) -> tuple[str, str]:
    content_type = (
        mimetypes.guess_type(path.name)[0]
        or "application/octet-stream"
    )
    response = requests.post(
        f"{API_ROOT}/assets",
        headers={
            "Authorization": f"Bearer {api_key}",
            "Content-Type": "application/json",
        },
        json={
            "contentType": content_type,
            "description": f"Upload de {path.name}",
        },
        timeout=30,
    )
    response.raise_for_status()
    data: dict[str, Any] = response.json()

    asset_id = (
        data.get("assetId")
        or data.get("id")
        or data.get("asset_id")
    )
    upload_url = (
        data.get("uploadUrl")
        or data.get("upload_url")
        or data.get("url")
    )

    if not isinstance(asset_id, str) or not isinstance(upload_url, str):
        raise RuntimeError(
            "Resposta de criação de asset com schema inesperado: "
            f"{list(data.keys())}"
        )

    return asset_id, upload_url


def upload_file(upload_url: str, path: Path) -> None:
    content_type = (
        mimetypes.guess_type(path.name)[0]
        or "application/octet-stream"
    )
    with path.open("rb") as stream:
        response = requests.put(
            upload_url,
            data=stream,
            headers={"Content-Type": content_type},
            timeout=300,
        )
    response.raise_for_status()


def main() -> None:
    api_key = os.environ["NVIDIA_API_KEY"]
    path = Path(os.environ["NVIDIA_ASSET_FILE"]).resolve()
    if not path.is_file():
        raise FileNotFoundError(path)

    asset_id, upload_url = create_asset(api_key, path)
    upload_file(upload_url, path)
    print(f"Asset enviado: {asset_id}")
    print(
        "Use o ID conforme a página da função, geralmente em "
        "NVCF-INPUT-ASSET-REFERENCES."
    )


if __name__ == "__main__":
    main()
