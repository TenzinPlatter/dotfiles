#!/usr/bin/env python3
"""Tests for the llm script."""

import pytest
from unittest.mock import Mock, patch, call, MagicMock
import subprocess
import json
import sys
import os

# Load the llm script as a module by exec-ing it
llm_path = os.path.join(os.path.dirname(os.path.abspath(__file__)), "llm")
with open(llm_path) as f:
    llm_code = f.read()
llm_module = type(sys)('llm')
exec(llm_code, llm_module.__dict__)
sys.modules['llm'] = llm_module


def test_basic_mode_sends_prompt_to_ollama(capsys):
    """Test that basic mode sends the prompt to ollama and streams the response."""
    with patch('llm.urllib.request.urlopen') as mock_urlopen:
        # Mock the streaming response from ollama
        mock_response = Mock()
        mock_response.__enter__ = Mock(return_value=mock_response)
        mock_response.__exit__ = Mock(return_value=False)
        mock_response.read = Mock(side_effect=[
            b'{"response": "Hello", "done": false}\n',
            b'{"response": " world", "done": false}\n',
            b'{"response": "!", "done": true}\n',
            b''
        ])
        mock_urlopen.return_value = mock_response

        # Run the main function
        result = llm_module.main(['what is 2+2'])

        # Verify the request was made to ollama
        assert mock_urlopen.called
        call_args = mock_urlopen.call_args
        request = call_args[0][0]
        assert 'localhost:11434/api/generate' in request.full_url

        # Verify request body
        request_data = json.loads(request.data.decode())
        assert request_data['model'] == 'llama3.2:3b'
        assert request_data['prompt'] == 'what is 2+2'
        assert request_data['stream'] is True

        # Verify output was streamed
        captured = capsys.readouterr()
        assert captured.out == 'Hello world!'

        # Verify exit code
        assert result == 0


def test_build_mode_executes_command_and_parses_errors(capsys):
    """Test that build mode runs a command and parses errors with AI."""
    with patch('llm.subprocess.run') as mock_run, \
         patch('llm.urllib.request.urlopen') as mock_urlopen:

        # Mock the build command output with errors
        mock_run.return_value = Mock(
            returncode=1,
            stdout='Building project...\nsrc/main.c:42:5: error: undefined reference to foo\nsrc/util.c:10:12: warning: unused variable bar\n',
            stderr=''
        )

        # Mock the AI response that parses the errors
        mock_response = Mock()
        mock_response.__enter__ = Mock(return_value=mock_response)
        mock_response.__exit__ = Mock(return_value=False)
        mock_response.read = Mock(side_effect=[
            b'{"response": "src/main.c:42:5: error: undefined reference to foo\\n", "done": false}\n',
            b'{"response": "src/util.c:10:12: warning: unused variable bar\\n", "done": true}\n',
            b''
        ])
        mock_urlopen.return_value = mock_response

        # Run the build mode
        result = llm_module.main(['--build', 'make', 'test'])

        # Verify build command was executed
        assert mock_run.called
        call_args = mock_run.call_args
        assert call_args[0][0] == ['make', 'test']
        assert call_args[1].get('capture_output') is True
        assert call_args[1].get('text') is True

        # Verify AI was called with correct model and prompt
        assert mock_urlopen.called
        call_args = mock_urlopen.call_args
        request = call_args[0][0]
        request_data = json.loads(request.data.decode())
        assert request_data['model'] == 'llama3.2:1b'
        assert 'parse' in request_data['prompt'].lower() or 'error' in request_data['prompt'].lower()
        assert 'src/main.c:42:5: error' in request_data['prompt']

        # Verify parsed errors were output
        captured = capsys.readouterr()
        assert 'src/main.c:42:5: error: undefined reference to foo' in captured.out
        assert 'src/util.c:10:12: warning: unused variable bar' in captured.out

        # Verify exit code matches build command exit code
        assert result == 1


def test_connection_error_handling(capsys):
    """Test that connection errors to ollama are handled gracefully."""
    import urllib.error

    with patch('llm.urllib.request.urlopen') as mock_urlopen:
        # Mock a connection error
        mock_urlopen.side_effect = urllib.error.URLError("Connection refused")

        # Run should exit with error
        result = llm_module.main(['what is 2+2'])

        # Verify error message
        captured = capsys.readouterr()
        assert 'Error: Could not connect to ollama' in captured.err or 'Error: Could not connect to ollama' in captured.out
        assert 'ollama serve' in captured.err or 'ollama serve' in captured.out

        # Verify exit code is non-zero
        assert result == 1


def test_empty_prompt_shows_usage(capsys):
    """Test that empty prompts show usage message."""
    result = llm_module.main([])

    captured = capsys.readouterr()
    output = captured.out + captured.err
    assert 'usage' in output.lower() or 'Usage' in output

    assert result == 1


def test_build_mode_without_command_shows_usage(capsys):
    """Test that --build without a command shows usage message."""
    result = llm_module.main(['--build'])

    captured = capsys.readouterr()
    output = captured.out + captured.err
    assert 'usage' in output.lower() or 'Usage' in output

    assert result == 1
