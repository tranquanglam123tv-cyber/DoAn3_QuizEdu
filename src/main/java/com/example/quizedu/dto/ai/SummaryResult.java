package com.example.quizedu.dto.ai;

import lombok.Data;

import java.util.List;

@Data
public class SummaryResult {
    private String overview;
    private List<String> keyPoints;
}
