#include <Windows.h>
#include <iostream>
#include <fstream>
#include <string>
#include <filesystem>
#include <urlmon.h>
#pragma comment( lib, "urlmon.lib" )

bool descargarArchivo( const std::wstring& url, const std::wstring& destino )
{
    HRESULT hr = URLDownloadToFileW( nullptr, url.c_str(), destino.c_str(), 0, nullptr );
    return SUCCEEDED( hr );
}

int main( int argc, char* argv[] )
{
    if( argc < 2 )
    {
        std::cerr << "Error: Please, drag and drop a .res file into this executable. " << std::endl;
        std::cin.get();
        return 1;
    }

    std::string File = argv[1];

    std::ifstream archivoRes( File );

    if( !archivoRes.is_open() )
    {
        std::cerr << "Error: Couldn't open file " << File << std::endl;
        std::cin.get();
        return 1;
    }

    wchar_t exePath[MAX_PATH];
    GetModuleFileNameW(nullptr, exePath, MAX_PATH);
    std::wstring exeDir = std::filesystem::path(exePath).parent_path();

    std::wstring githubBaseUrl = L"https://github.com/Mikk155/Sven-Co-op/raw/main/";

    std::string linea;

    while( std::getline( archivoRes, linea ) )
    {
        std::wstring path = std::wstring(linea.begin() + 1, linea.end() - 1);

        std::wstring archivoEnGithub = githubBaseUrl + path;

        std::wstring destino = exeDir + L"\\" + path;

        // Extraemos el directorio de destino
        std::filesystem::path destPath(destino);
        std::filesystem::path destDir = destPath.parent_path();

        // Creamos el directorio si no existe
        std::filesystem::create_directories(destDir);

        if( descargarArchivo( archivoEnGithub, destino ) )
        {
            std::wcout << L"Installed file: " << destino << std::endl;
        }
        else
        {
            std::wcerr << L"Error downloading file: " << archivoEnGithub << std::endl;
        }
    }

    std::cout << "All done. press Enter to exit...";
    std::cin.get();

    return 0;
}
